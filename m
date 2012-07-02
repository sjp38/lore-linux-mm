Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id AE5CB6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 01:22:44 -0400 (EDT)
Date: Mon, 2 Jul 2012 13:22:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: linux-next BUG: held lock freed!
Message-ID: <20120702052241.GA8476@localhost>
References: <20120626145432.GA15289@localhost>
 <20120626172918.GA16446@localhost>
 <20120627122306.GA19252@localhost>
 <20120702025625.GA6531@localhost>
 <CA++bM2txX2f=SC3r3bwxLcB8CUCuELW-NhytrKW7-07kysfA2A@mail.gmail.com>
 <20120702122858.029946db@feng-i7>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120702122858.029946db@feng-i7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Feng Tang <feng.tang@intel.com>
Cc: Christoph Lameter <cl@linux.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>, penberg@kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, bfields@fieldses.org

> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3890,7 +3890,7 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
>         unsigned long flags;
>  
>         local_irq_save(flags);
> -       debug_check_no_locks_freed(objp, cachep->size);
> +       debug_check_no_locks_freed(objp, cachep->object_size);
>         if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
>                 debug_check_no_obj_freed(objp, cachep->object_size);
>         __cache_free(cachep, objp, __builtin_return_address(0));

It works! No single error after a dozen reboots :-)

Tested-by: Fengguang Wu <wfg@linux.intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
