Date: Mon, 6 Oct 2003 00:02:01 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Code that does page outs
Message-Id: <20031006000201.1804ba97.pj@sgi.com>
In-Reply-To: <20031006063253.GA5231@despammed.com>
References: <20031006063253.GA5231@despammed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eugene Teo <eugeneteo@despammed.com>
Cc: eugene.teo@eugeneteo.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I am looking for possible areas in the kernel code where ...

May I recommend to you the site:

   Cross-Referencing Linux
   http://lxr.linux.no

For example, start with an "identifier search" on one of the symbols you
identified, try_to_swap_out:

   http://lxr.linux.no/ident?i=try_to_swap_out

This page will show where it is defined, and what calls it. Examine the
code that defines try_to_swap_out().  Observe the critical between lines
133 and 148 of this file, vmscan.c. This is where it gets a free swap
entry, get_swap_page(), and assigns the current page to that entry,
add_to_swap_cache().

I would expect that any other piece of code that wants to swap is going
to use those same routines, get_swap_page(), and add_to_swap_cache(). 
Though examining these two routines in detail and what they call in turn
would help to verify that expectation.

Then continue using lxr.linux.no to see what else, if anything, calls
this pair of routines: get_swap_page(), and add_to_swap_cache().

This will lead you to any other paths, if any, to swapping a page.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
