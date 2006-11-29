Message-ID: <456D4722.2010202@yahoo.com.au>
Date: Wed, 29 Nov 2006 19:38:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com> <20061129082650.GB12734@infradead.org>
In-Reply-To: <20061129082650.GB12734@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Mon, Nov 27, 2006 at 10:33:28PM -0800, Christoph Lameter wrote:
> 
>>slab.h really defines multiple APIs. One is the classic slab api
>>where one can define a slab cache by specifying exactly how
>>the slab has to be generated. This API is not frequently used.
>>
>>Another is the kmalloc API. Quite a number of kernel source code files 
>>need kmalloc but do not need to generate custom slabs. The kmalloc API 
>>also use some funky macros that may be better isolated in an additional .h 
>>file in order to ease future cleanup. Make kmalloc.h self contained by 
>>adding two extern definitions local to kmalloc and kmalloc_node.
>>
>>Then there is the SLOB api mixed in with slab. Take that out and define it 
>>in its own header file.
> 
> 
> NACK.  This is utterly braindead, easily shown by things like the need
> to duplicate the kmem_cache_alloc prototype.
> 
> What are you trying to solve with this?

It does seem wrong, I agree. For another thing, there is no "slob API".
Slob is an implementation of the *slab API*.

kmalloc seems OK to be split. But given that it is built on top of the
slab, then it should not be going out of its way to avoid the slab.h
include, as Christoph H points out.

If this whole exercise is to dispense with a few includes, then I'll
second Christoph's nack. This kinds of tricks does not make it easier
to untangle and redesign header dependencies properly in the long term.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
