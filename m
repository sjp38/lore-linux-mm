Date: Tue, 24 Apr 2007 23:23:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
In-Reply-To: <20070424182212.bbe76894.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704242322300.21125@schroedinger.engr.sgi.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
 <1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com>
 <20070424155151.644e88b7.akpm@linux-foundation.org>
 <1177462288.1281.11.camel@dyn9047017100.beaverton.ibm.com>
 <20070424182212.bbe76894.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007, Andrew Morton wrote:

> > gcc version 4.1.0 -- doesn't generate this error
> 
> My power box is 3.4.4 and it doesn't do that either.  I guess it's just a
> gcc buglet.

Its a constant folding issue. Yuck. I went through a series of these last 
year and I thought I had this under constrol.
> 
> Poor Christoph ;)
> 
> I wonder why slab doesn't hit that problem.

It relies less on constant folding.
 
> I wonder whether slub should use kmalloc-sizes.h.

I tried to avoid that mess.

What is the lowest gcc version we currently support?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
