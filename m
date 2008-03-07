Date: Fri, 7 Mar 2008 09:05:17 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-Id: <20080307090517.b6b27987.randy.dunlap@oracle.com>
In-Reply-To: <20080307090716.9D3E91B419C@basil.firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
	<20080307090716.9D3E91B419C@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  7 Mar 2008 10:07:16 +0100 (CET) Andi Kleen wrote:

> 
> This is the core code of the maskable allocator. Introduction
> appended.

> Index: linux/Documentation/kernel-parameters.txt
> ===================================================================
> --- linux.orig/Documentation/kernel-parameters.txt
> +++ linux/Documentation/kernel-parameters.txt
> @@ -2116,6 +2116,9 @@ and is between 256 and 4096 characters. 
>  	norandmaps	Don't use address space randomization
>  			Equivalent to echo 0 > /proc/sys/kernel/randomize_va_space
>  
> +	maskzone=size[MG] Set size of maskable DMA zone to size.
> +		 force	Always allocate from the mask zone (for testing)

                 ^^^^^^^^^^^^^ ??

> +
>  ______________________________________________________________________
>  
>  TODO:

> Index: linux/Documentation/DocBook/kernel-api.tmpl
> ===================================================================
> --- linux.orig/Documentation/DocBook/kernel-api.tmpl
> +++ linux/Documentation/DocBook/kernel-api.tmpl
> @@ -164,6 +164,7 @@ X!Ilib/string.c
>  !Emm/memory.c
>  !Emm/vmalloc.c
>  !Imm/page_alloc.c
> +!Emm/mask-alloc.c
>  !Emm/mempool.c
>  !Emm/dmapool.c
>  !Emm/page-writeback.c

Thanks for the kernel-doc annotations.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
