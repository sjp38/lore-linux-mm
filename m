Subject: Re: mm/slub.c: inconsequent NULL checking
In-Reply-To: <20080219224922.GO31955@cs181133002.pp.htv.fi>
Message-ID: <6f8gTuy3.1203515564.2078250.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Wed, 20 Feb 2008 15:52:44 +0200 (EET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bunk@kernel.org, clameter@sgi.com, penberg@cs.helsinki.fi, mpm@selenic.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Adrian,

On 2/20/2008, "Adrian Bunk" <bunk@kernel.org> wrote:
> The Coverity checker spotted the following inconsequent NULL checking
> introduced by commit 8ff12cfc009a2a38d87fa7058226fe197bb2696f:
> 
> <--  snip  -->
> 
> ...
> static inline int is_end(void *addr)
> {
>         return (unsigned long)addr & PAGE_MAPPING_ANON;
> }
> ...
> static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
> {
> ...
>         if (c->freelist)    <----------------------------------------
>                 stat(c, DEACTIVATE_REMOTE_FREES);

I spotted this too. c->freelist should never be NULL so why not send a
patch to Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
