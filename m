Date: Mon, 14 May 2007 08:51:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/5] mm: slab allocation fairness
In-Reply-To: <20070514133212.399158218@chello.nl>
Message-ID: <Pine.LNX.4.64.0705140850540.10442@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl> <20070514133212.399158218@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> @@ -3182,13 +3192,13 @@ static inline void *____cache_alloc(stru
>  	check_irq_off();
>  
>  	ac = cpu_cache_get(cachep);
> -	if (likely(ac->avail)) {
> +	if (likely(ac->avail) && !slab_insufficient_rank(cachep, rank)) {
>  		STATS_INC_ALLOCHIT(cachep);
>  		ac->touched = 1;

Hotpath modifications.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
