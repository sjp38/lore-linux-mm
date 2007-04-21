Date: Fri, 20 Apr 2007 22:37:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab allocators: Remove multiple alignment specifications.
Message-Id: <20070420223727.7b201984.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 22:12:52 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> --- linux-2.6.21-rc6.orig/arch/sparc64/mm/init.c	2007-04-20 19:25:14.000000000 -0700
> +++ linux-2.6.21-rc6/arch/sparc64/mm/init.c	2007-04-20 19:25:40.000000000 -0700
> @@ -191,7 +191,7 @@ void pgtable_cache_init(void)
>  {
>  	pgtable_cache = kmem_cache_create("pgtable_cache",
>  					  PAGE_SIZE, PAGE_SIZE,
> -					  SLAB_HWCACHE_ALIGN,
> +					  0,
>  					  zero_ctor,
>  					  NULL);

You're patching code which your earlier patches deleted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
