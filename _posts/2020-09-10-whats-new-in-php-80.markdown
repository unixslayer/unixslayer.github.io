---
title: What's new in PHP 8.0
layout: post
date: 2020-09-10
categories: [tech]
tags: [workshop, php, php8, new-features, improvements]
---

PHP 8.0 is right behind a corner. By now [PHP 8.0.0 Beta 3 is available for testing](https://www.php.net/archive/2020.php#2020-09-03-3) and RC1 is planned for September 17. Beside [JIT](https://wiki.php.net/rfc/jit), few interesting features are introduced with this major version.

## Union types

This one is quite interesting. Have you ever wrote or seen code like this one?

```php
<?php

/**
 * @param int|float $param
 */
function foo($param) {
    //logic
}
```

Let's assume that this is a desired behavior and `foo` allows to pass `int` or `float` as a parameter. Without typehint, we must implement type assertion to make sure that no other type will be passed. 

With union types we will be able to do this:

```php
<?php

function foo(int|float $param) {
    //logic
}
```

As you can see, no additional type assertion is required, which resolves in less code to write. There is also no additional and unnecessary `docblock`. This also applies for return types as well. Check RFC to get full closure on this feature. 

Union types may be considered as controversial since it can promote bad practices. But bad practices are promoted by programmers and organizations and can be satisfied by many other things. By adopting certain standards, we limit the propagation of bad practices, but it cannot be entirely avoided, because it does not only depend on the tool.

[PHP RFC: Union Types 2.0](https://wiki.php.net/rfc/union_types_v2)

## Constructor Property Promotion

This one simplifies class property declaration introducing simpler and faster synthax. Consider following example:

```php
<?php

class Point {
    public float $x;
    public float $y;
    public float $z;
 
    public function __construct(
        float $x = 0.0,
        float $y = 0.0,
        float $z = 0.0,
    ) {
        $this->x = $x;
        $this->y = $y;
        $this->z = $z;
    }
}
```

In this case, each property declaration is quite a boilerplate. Property name is repeated 4 times and its type was repeated twice. Even if this can be simplyfied with your IDE to quickly initialize properties, there is still a lot of code when you have only few simple properties that doesn't require additional logic. 

Now consider this example:

```php
<?php

class Point {
    public function __construct(
        public float $x = 0.0,
        public float $y = 0.0,
        public float $z = 0.0,
    ) {}
}
```

Nice, right? Constructor property promotion makes attributes declared without any additional code. In this example object will be instantiated with 3 public properties. Also both promoted and non-promoted properties are possible within the same constructor. 

There are some limitations to this feature:

- promotion can only be done in non-abstract constructors
- promoted properties cannot be redeclared in standard way
- callable type is not supported
- variadic parameters cannot be promoted

[PHP RFC: Constructor Property Promotion](https://wiki.php.net/rfc/constructor_promotion)

## Getting classname from object

This one is trivial, yet may simplify your codebase. Up until PHP 8 to get class name literal of an object we had to use `get_class($object)`. New version allows you to use `$object::class` which looks more intuitive.

[PHP RFC: Allow ::class on objects](https://wiki.php.net/rfc/class_name_literal_on_object)

## non-capturing catches

This one is pretty straightforward. Catching exceptions in PHP require to capture it into a variable. But there can be some situations that exception details are irrelevant and variable is never used. If programmer wont use it in catch block, it may be considered as bug - unused variable is introduced eventually.

New feature lets to omit unnecessary variable.

```php
try {
    doSomething();
} catch (\LogicException) { // The intention is clear: exception details are irrelevant
    echo "It is illogical to do something.";
}
```

[PHP RFC: non-capturing catches](https://wiki.php.net/rfc/non-capturing_catches)

## Handy string functions

If you ever had to check two strings between each other, you had to use combination with `substr`, `subpos` and `strlen`:

```php
<?php

// check if string ends with needle
substr($haystack, -strlen($needle)) === $needle;

//check if string starts with needle
substr($haystack, 0, strlen($needle)) === $needle;

//check if string do not start with needle
substr($haystack, 0, strlen($needle)) !== $needle;

//check if string contains another string
strpos('abc', 'a') !== false;
```

New functions are introduced to simplify those operations:

```php
<?php 

// check if string ends with needle
str_ends_with($haystack, $needle);

//check if string starts with needle
str_starts_with($haystack, $needle);

//check if string do not start with needle
!str_starts_with($haystack, $needle);

//check if string contains another string
str_contains('abc', 'a');
```

[](https://wiki.php.net/rfc/add_str_starts_with_and_ends_with_functions)
[](https://wiki.php.net/rfc/str_contains)