Date: Mon, 4 Sep 2000 14:03:25 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: stack overflow
Message-ID: <20000904140325.Y22907@mea-ext.zmailer.org>
References: <20000904104744.2259.qmail@web6402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000904104744.2259.qmail@web6402.mail.yahoo.com>; from zeshan_uet@yahoo.com on Mon, Sep 04, 2000 at 03:47:44AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zeshan Ahmad <zeshan_uet@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 04, 2000 at 03:47:44AM -0700, Zeshan Ahmad wrote:
> Hi
> 
> Can any1 tell me how can the stack size be changed in
> the Kernel. i am experiencing a stack overflow problem

	In kernel ?  DON'T!

> when the function kmem_cache_sizes_init is called in
> /init/main.c The exact place where the stack overflow
> occurs is in the function kmem_cache_slabmgmt in
> /mm/slab.c
> 
> Is there any way to change the stack size in Kernel?
> Can the change in stack size simply solve this Kernel
> stack overflow problem?

	That is indicative that somewhere along the path
	you are:  a) recursin, b) otherwise wasting stack
	with too large local allocations (e.g. "auto"
	variables).

	In the kernel space: NEVER use stack-based buffers,
	always  kmalloc().  (If they are more than 8-16 bytes
	in size, that is.)  Similarly, NEVER use alloca() !

> Urgent help is needed.
> 
> ZEESHAN

/Matti Aarnio
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
