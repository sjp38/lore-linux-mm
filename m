Date: Tue, 10 Oct 2006 10:07:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
In-Reply-To: <20061010000331.bcc10007.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0610101001480.927@schroedinger.engr.sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
 <20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
 <20061009111203.5dba9cbe.akpm@osdl.org> <20061009150259.d5b87469.pj@sgi.com>
 <20061009215125.619655b2.pj@sgi.com> <Pine.LNX.4.64N.0610092331120.17087@attu3.cs.washington.edu>
 <20061010000331.bcc10007.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: David Rientjes <rientjes@cs.washington.edu>, akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Could it be worth to investigate more radical ideas? This gets way too 
complicated for me. Maybe drop the whole zone list generation idea and 
iterate over nodes in another way?

1. Have an allocator that is not node aware and can just deal with
memory in up to 3 different zones. No NUMA at all.

2.  Have another NUMA allocator that uses the node unaware allocator
but implements its own way of handling the NUMA situation with proper 
fallbacks etc etc. Maybe we could then merge the allocation logic
from mempolicy.c into the page allocator?

If 2 is generic enough then it can be used for other allocators as well 
(like slab, hugepages, uncaches allocators) and provide a coherent 
NUMA allocation handling for all allocators on NUMA.

It would be great if we could simplify and modularize the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
