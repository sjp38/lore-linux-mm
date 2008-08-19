Message-ID: <48AB0D69.4090703@linux-foundation.org>
Date: Tue, 19 Aug 2008 13:14:01 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with _RET_IP_.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:

>  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
>  {
> -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> +	return slab_alloc(s, gfpflags, -1, (void *) _RET_IP_);
>  }

Could you get rid of the casts by changing the type of parameter of slab_alloc()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
