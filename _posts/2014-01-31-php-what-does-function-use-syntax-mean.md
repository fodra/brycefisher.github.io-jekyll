---
title: "PHP: What Does function ...() use () syntax mean?"
layout: "post"
excerpt: "Mastering some of more idiosyncratic syntax of PHP is tricky these days with a much faster release cycle in recent years. Here's one syntax that I've seen a lot lately in PHP's \"Closures\" (aka lambda functions) but could never wrap my head around until tonight: the mysterious PHP function use syntax. TL;DR - use() passes variables from the scope outside the closure into the closure itself. If you're used to closures in JavaScript, get ready for a new twist."
category: php
---
I've recently seen an unfamiliar syntax all over the place, but I didn't understand it and I couldn't find anything about it while searching. Here's a sample:


{% highlight php %}
<?php
// ...
$loop->onReadable($server, function ($server) use ($loop) {
    // ...
});
?>
{% endhighlight %}
    
[From igorw's github](https://github.com/igorw/webserver-zceu/blob/master/08-async-echo.php). Did you catch it? Why is there a "use" statement after a function? Googling "php use function" wasn't any help. 

## Buried Deep in the PHP Manual - A Clue

After an hour of wandering through the PHP documentation (which I actually quite like doing anyway), I discovered this [very helpful comment](http://www.php.net/manual/en/language.namespaces.php#104136):

> The keyword 'use' has two different applications, but the reserved word table links to here.
> 
> It can apply to namespace constucts:

Namespaces are pretty cool. They form the foundation of PSR-0, Composer, and everything good in the PHP these days. But, that syntax is used at the top of files on it's own line. Then, I found the answer:

> The 'use' keyword also applies to closure constructs:

## Closures: A (JavaScripty) World Within

I've seen the term "closure" in PHP before, but I'm most familiar with it inside Javascript. A closure in PHP simply refers to *any* anonymous function, even in the global scope. However, PHP 5.3 introduced this sneaky new syntax whereby you can copy variables out of the parent scope and into the "closure" scope. Nifty, huh? Here's what [the PHP documentation has to say on the use syntax](http://www.php.net/manual/en/functions.anonymous.php):

> Closures may also inherit variables from the parent scope. Any such variables must be passed to the `use` language construct. Inheriting
> variables from the parent scope is not the same as using global variables. Global variables exist in the global scope, which is the same
> no matter what function is executing. The parent scope of a closure is the function in which the closure was declared (not necessarily the
> function it was called from).

## Parameters by Any Other Name

Just like normal function parameters, parameters provided to the closure scope via the `use` keyword are **passed by value**. To pass parameters by reference, simply add an ampersand (&amp;) in front of the parameter.

## Exciting Uses of Closures and the Use Keyword

I've been trying to figure out to hack together a pure PHP server using PHP 5.3 for a special side project, and I came upon the excellent static site generator called [Sculpin](http://github.com/sculpin/sculpin). It's PHAR can be called from the command line just like Jekyll. It also has a special flag `--server` that spins up a server on the spot, even using PHP 5.3! Intrigued, I dug into the source code and finally found an [evented PHP server inspired by NodeJS](https://github.com/sculpin/sculpin/blob/master/src/Sculpin/Bundle/SculpinBundle/HttpServer/HttpServer.php). Here's a few key parts of the code:

{% highlight php %}
<?php
// ...
$httpServer = new ReactHttpServer($socketServer);
$httpServer->on("request", function($request, $response) use ($repository, $docroot, $output) {
    $path = $docroot.'/'.ltrim(rawurldecode($request->getPath()), '/');
    if (is_dir($path)) {
        $path .= '/index.html';
    }
    if (!file_exists($path)) {
        HttpServer::logRequest($output, 404, $request);
        $response->writeHead(404);
        return $response->end();
    }

    // ...

    $response->writeHead(200, array(
        "Content-Type" => $type,
    ));
    $response->end(file_get_contents($path));
});
$socketServer->listen($port, '0.0.0.0');
// ...
{% endhighlight %}

## A Brighter Future

I really hope that the future of PHP is a future that's less tied to Apache. That worked well in the past, but it's just too hard to provision and tweak Apache when you just want to write. Source code like this inspires me to believe that it's possible to handle all of our routing logic without having to rely on some other piece of software to ferry requests from the network to our application and back again.

Where have you seen `use` done right? Let me know your thoughts on this and other esoterica from recent versions of PHP.
