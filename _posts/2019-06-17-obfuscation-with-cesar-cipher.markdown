---
title: Obfuscation with Cesar Cipher
layout: post
date: 2019-06-17
categories: [Developer workshop]
tags: [cesar cipher, cryptography, obfuscation, php, rot13, security]
---

Cryptography is everywhere. Securing data, connections, authorizations, anonymity, cryptocurrency, blockchain. Everywhere. Lately I’ve been digging into cryptography and found out that I know nothing about it. Or not as much as I thought. As for myself cryptography was underestimate and at least used incorrectly.

I’m going to share my journey with cryptography, but please take it with a grain of salt, because I’m not an expert (yet?) in this area. It will be more of a paraphrase of what I’ve learn so far. Make notice, that if you also don’t have any skills in cryptography, all you’ll need to know for start is basic algebra. Nothing more. OK maybe basic knowledge of PHP will be also helpful ;)

Lets start with obfuscation. It helps us to encode something and make it hard to read with possibility to decode it back to legible form. There are may ways to manage that and each method will be described separately. For start, lets look at `Cesar Cipher`.

This is the most basic and apparently well known encryption technique used in ancient times by Julius Cesar himself. To encode a message you essentially replaced each character by a letter from a cipher which become from shifting letters by given amount according to the alphabet. This method is called as substitution cipher.

Say, you have an Latin alphabet

```
abcdefghijklmnopqrstuvwxyz
```

and you want to encode a message, e.g. ‘hello’ using 3 as a shift (like Julius Cesar did). That way cipher will be the same alphabet, but shifted s steps to the right

```
abcdefghijklmnopqrstuvwxyz
||||||||||||||||||||||||||
defghijklmnopqrstuvwxyzabc
```

This means that every letter in the alphabet becomes one from the cipher on the corresponding location. Our message would be ‘khoor’ in this example.

Try to write some code for this:

```php
<?php
 
$string = 'hello';
$alpha = 'abcdefghijklmnopqrstuvwxyz';
$shift = 3;
$result = '';
 
foreach(str_split($string) as $character) {
    $cipherLocation = strpos($alpha, $character) + $shift;
    $result .= substr($alpha, $cipherLocation, 1);
}
```

This should be pretty obvious. We iterate each character of our $string, seek for its location in given alphabet, add shift amount to get location from cipher, and take whatever character there is.

Above solution has some flaws:

- it won’t handle spaces
- it won’t handle situation when character is not within the alphabet – here we can assume that it should remain on its position
- it will work only, if we don’t exceed number of characters in alphabet while shifting

The first twho issues are simple to handle but the last one is a bit tricky. As you can see, we have only 26 letters in Latin alphabet, so our `$cipherLocation` can be within range `0...25`. If it’s out of that range, we’ll have to add or subtract 26 from final location. If shift will be, lets say 15, encoded ‘hello’ will be ‘wt’. Try to decode that :)

Solution to that is really simple. To make sure that we won’t get out of range use modulo division by 26 which is the amount of letters in our alphabet.

```php
<?php
 
$string = 'hello';
$alpha = 'abcdefghijklmnopqrstuvwxyz';
$shift = 3;
$result = '';
 
foreach(str_split($string) as $character) {
    if ($character === ' ' || ($cipherLocation = (strpos($alpha, $character))) === false) {
        return $character;
    } else {
        $cipherLocation = ($cipherLocation + $shift) % 26;
        $result .= substr($alpha, $cipherLocation, 1);
    }
}
```

With this simple fix, we can now encode our message with huge shift (e.g. 300).

Lets close this script into nice function and make it more versatile:

```php
<?php
 
function cesar(string $string, int $shift = 3, string $alpha = 'abcdefghijklmnopqrstuvwxyz'): string
{
    $result = array_map(static function(string $character) use ($alpha, $shift) {
        if ($character === ' ' || ($cipherLocation = (strpos($alpha, $character))) === false) {
            return $character;
        } else {
            $cipherLocation = ($cipherLocation + $shift) % strlen($alpha);
            return substr($alpha, $cipherLocation, 1);
        }
    }, str_split($string));
     
    return implode('', $result);
}
```

To decode the message, we simply run the same function but this time, we have to shift in opposite direction:

```php
<?php
 
var_dump(cesar('hello', 3)); // will output: khoor
var_dump(cesar('khoor', -3)); // will output original message: hello
```

To break the cipher all we need to know is the alphabet used and shift direction. Assuming that we still have Latin alphabet and shift was made from left to right we can simply crack any message encoded this way:

```php
<?php
 
$message = 'lnbja lryqna rb anjuh brvyun lahycx cnlqwrzdn';
 
foreach (range(-25, 0) as $shift) {
    var_dump(cesar($message, $shift));
}
```

There is an interesting version of Cesar Cipher called `ROT13` (Cesar Cipher with shift of 13). ROT13 is its own inverse which means that if you want to decode message, simply apply the same method to encoded value.

Final code with additional tests is placed [here](https://github.com/unixslayer/cryptography-php).

