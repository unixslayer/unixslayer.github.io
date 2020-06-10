---
title: How to retrieve all Variables from a Twig Template
layout: post
date: 2020-06-10
categories: [Developer workshop]
tags: [symfony, symfony 5, framework, twig, extensions, debug]
---

Just had to figure out how to retrieve all variables from a Twig Template. Of course there is a `DebugExtension` which allows me to use {% raw %}`{{ dump() }}`{% endraw %} in template. But I couldn't use it because I wasn't rendering my template. Here is a scenario...

- application is used to send emails which content is a Twig templates, stored in database.
- templates can use variables within its content.
- user can send request to API to send message in chosen template. User can also send values for variables that are defined in template.

If you try to render template without passing expected variables, Twig will throw an exception. You can, of course, handle it in template by checking if variable is defined in current context, but some variables might by required and because users can define their own templates, this is not so obvious to do. We have decided to validate users request and check if all variables were send. We have template content, so we can always write awesome regular expression for that right? Well, not really. It would be better to use Twig for that.

When Twig creates a template it create small chunks defined as `Twig\Node\Node` objects which are used later for render. Expressions, like {% raw %}`{{ variable }}`{% endraw %}, are defined as `Twig\Node\PrintNode` which has its own nodes. Here we can have `Twig\Node\Expression\NameExpression` if variables are just printing, `Twig\Node\Expression\FilterExpression` if we use filters on variables and `Twig\Node\Expression\FunctionExpression` for function usage. Each of those `Expressions` can help us retrieve variable name which is contained in `name` attribute of that `Expression`. Enough said, lets dig in to code.

```php
class TemplateVariablesVisitor implements NodeVisitorInterface
{
    private array $params = [];

    public function params(): array
    {
        return $this->params;
    }

    public function leaveNode(Node $node, Environment $env): ?Node
    {
        return $node;
    }

    public function getPriority(): int
    {
        return 0;
    }

    public function enterNode(Node $node, Environment $env): Node
    {
        if (!$node->hasNode('body')) {
            return $node;
        }

        $bodyNodes = iterator_to_array($node->getNode('body')->getNode('0')->getIterator());

        $this->params = array_unique(array_reduce($bodyNodes, function (array $carrier, Node $node) {
            if ($node instanceof PrintNode) {
                $carrier = array_merge($carrier, $this->handleNode($node));
            }

            return $carrier;
        }, []));

        return $node;
    }

    private function handleNode(PrintNode $node): array
    {
        $expression = $node->getNode('expr')->getNode('node');
        if ($expression instanceof NameExpression) {
            return [$this->handleNameExpression($expression)];
        }
        if ($expression instanceof FilterExpression) {
            return [$this->handleFilterExpression($expression)];
        }
        if ($expression instanceof FunctionExpression) {
            return $this->handleFunctionExpression($expression);
        }
    }

    private function handleNameExpression(NameExpression $expressionNode): string
    {
        return $expressionNode->getAttribute('name');
    }

    private function handleFilterExpression(FilterExpression $expressionNode): string
    {
        return $expressionNode->getNode('node')->getAttribute('name');
    }

    private function handleFunctionExpression(FunctionExpression $expressionNode): array
    {
        $arguments = iterator_to_array($expressionNode->getNode('arguments')->getIterator());
        $variables = [];
        foreach ($arguments as $argument) {
            if ($argument instanceof NameExpression) {
                $variables[] = $this->handleNameExpression($argument);
            }
            if ($argument instanceof FilterExpression) {
                $variables[] = $this->handleFilterExpression($argument);
            }
            if ($argument instanceof FunctionExpression) {
                $variables = array_merge($variables, $this->handleFunctionExpression($argument));
            }
        }

        return $variables;
    }
}
```

```php
use Twig\Environment;
use Twig\Loader\ArrayLoader;
use Twig\Node\Node;
use Twig\Node\PrintNode;
use Twig\NodeVisitor\NodeVisitorInterface;

$twig = new Environment(new ArrayLoader());
$visitor = new TemplateVariablesVisitor();
$twig->addNodeVisitor($visitor);
{% raw %}
$template = <<<TWIG
simple variable {{ variable1 }}
multiline {{ variable2 }}

filters {{ variable3|upper }}
functions {{ max(variable1, variable2|upper, min(variable3)) }}
TWIG;
{% endraw %}
$twig->createTemplate($template);

var_dump($visitor->params());
```

```bash
array(3) {
  [0] =>
  string(9) "variable1"
  [1] =>
  string(9) "variable2"
  [2] =>
  string(9) "variable3"
}
```

This is not very pretty solution, but it works just fine on `Symfony v5.0` and `Twig v3.0`.