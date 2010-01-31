Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4E9F86B0088
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:32:22 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 09/10] mm/slab.c: Fix continuation line formats
Date: Sun, 31 Jan 2010 21:32:18 +0100
References: <cover.1264967493.git.joe@perches.com> <cover.1264967493.git.joe@perches.com> <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
In-reply-To: <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201001312132.19798.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Joe Perches wrote:
> String constants that are continued on subsequent lines with \
> are not good.

Fun. I'd done the same grep earlier today. AFAICT you've got all the
ones I had.

> The characters between seq_printf elements are tabs.
> That was probably not intentional, but isn't being changed.
> It's behind an #ifdef, so it could probably become a single space.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  mm/slab.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 7451bda..9964619 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4228,8 +4228,8 @@ static int s_show(struct seq_file *m, void *p)
>  unsigned long node_frees = cachep->node_frees;
>  unsigned long overflows = cachep->node_overflow;
>  
> -		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
> -				%4lu %4lu %4lu %4lu %4lu", allocs, high, grown,
> +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu 				%4lu %4lu %4lu %4lu %4lu",
> +				allocs, high, grown,
>  				reaped, errors, max_freeable, node_allocs,
>  				node_frees, overflows);
>  }

If that spacing part is really needed (is it?), wouldn't it be more
readable as:
> +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu"
> +				" 				"
> +				"%4lu %4lu %4lu %4lu %4lu",  
> +				allocs, high, grown,

Also, are there supposed to be tabs in that spacing part?

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
