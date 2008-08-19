Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <linux-mm@kvack.org>; Tue, 19 Aug 2008 10:51:32 -0700
Date: Tue, 19 Aug 2008 10:51:32 -0700 (PDT)
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
In-Reply-To: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
Message-ID: <Pine.LNX.4.64.0808191049260.7877@shark.he.net>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Aug 2008, Eduard - Gabriel Munteanu wrote:

> This reverts commit 79cf3d5e207243eecb1c4331c569e17700fa08fa.
> 
> The reverted commit, while it fixed printk format warnings, it resulted in
> marker-probe format mismatches. Another approach should be used to fix
> these warnings.

Such as what?

Can marker probes be fixed instead?

After seeing & fixing lots of various warnings in the last few days,
I'm thinking that people don't look at/heed warnings nowadays.  Sad.
Maybe there are just so many that they are lost in the noise.


> ---
>  include/linux/kmemtrace.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/kmemtrace.h b/include/linux/kmemtrace.h
> index a865064..2c33201 100644
> --- a/include/linux/kmemtrace.h
> +++ b/include/linux/kmemtrace.h
> @@ -31,7 +31,7 @@ static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
>  					     int node)
>  {
>  	trace_mark(kmemtrace_alloc, "type_id %d call_site %lu ptr %lu "
> -		   "bytes_req %zu bytes_alloc %zu gfp_flags %lu node %d",
> +		   "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d",
>  		   type_id, call_site, (unsigned long) ptr,
>  		   bytes_req, bytes_alloc, (unsigned long) gfp_flags, node);
>  }
> 

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
