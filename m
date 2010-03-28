Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 39B3F6B01AC
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 13:10:10 -0400 (EDT)
Message-ID: <4BAF8D6A.4000905@cs.helsinki.fi>
Date: Sun, 28 Mar 2010 20:10:02 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] mm: Fix continuation lines
References: <cover.1269655208.git.joe@perches.com> <c53e66323c5898fe17221c0813779862189abce3.1269655209.git.joe@perches.com>
In-Reply-To: <c53e66323c5898fe17221c0813779862189abce3.1269655209.git.joe@perches.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.

> ---
>  mm/slab.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index a9f325b..ceb4e3a 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4227,10 +4227,11 @@ static int s_show(struct seq_file *m, void *p)
>  		unsigned long node_frees = cachep->node_frees;
>  		unsigned long overflows = cachep->node_overflow;
>  
> -		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
> -				%4lu %4lu %4lu %4lu %4lu", allocs, high, grown,
> -				reaped, errors, max_freeable, node_allocs,
> -				node_frees, overflows);
> +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu "
> +			   "%4lu %4lu %4lu %4lu %4lu",
> +			   allocs, high, grown,
> +			   reaped, errors, max_freeable, node_allocs,
> +			   node_frees, overflows);
>  	}
>  	/* cpu stats */
>  	{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
