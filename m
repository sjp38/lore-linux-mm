Date: Wed, 6 Dec 2006 02:53:52 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: Call to cpuset_zone_allowed() in slab.c:fallback_alloc() with
 irqs disabled
Message-Id: <20061206025352.b1d9d63a.pj@sgi.com>
In-Reply-To: <6599ad830611221634w6a768c1ek816dda61a97b68c@mail.gmail.com>
References: <6599ad830611221634w6a768c1ek816dda61a97b68c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

A couple of weeks ago, Paul M wrote:
I just saw this backtrace on 2.6.19-rc5:
>
> BUG: sleeping function called from invalid context at kernel/cpuset.c:1520
> in_atomic():0, irqs_disabled():1
> 
> Call Trace:
>  ...
> 
> kmem_cache_alloc_node() disables irqs, then calls __cache_alloc_node()
> -> fallback_alloc() -> cpuset_zone_allowed(), with flags that appear
> to be GFP_KERNEL.

Thanks for reporting this - it looks like a missing __GFP_HARDWALL flag
on a new invocation of cpuset_zone_allowed().

I just sent a patch to lkml, and copied Christoph, since this is in his
code, just to be sure I didn't break something.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
