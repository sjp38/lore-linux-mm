Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D519B620001
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:08:47 -0500 (EST)
Subject: Re: [PATCH 09/10] mm/slab.c: Fix continuation line formats
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
References: <cover.1264967493.git.joe@perches.com>
	 <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 31 Jan 2010 14:08:43 -0600
Message-ID: <1264968523.3536.1801.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-31 at 12:02 -0800, Joe Perches wrote:
> String constants that are continued on subsequent lines with \
> are not good.

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
>  		unsigned long node_frees = cachep->node_frees;
>  		unsigned long overflows = cachep->node_overflow;
>  
> -		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
> -				%4lu %4lu %4lu %4lu %4lu", allocs, high, grown,
> +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu 				%4lu %4lu %4lu %4lu %4lu",
> +				allocs, high, grown,

Yuck. The right way to do this is by mergeable adjacent strings, eg:

printk("part 1..."
       " part 2...", ...);

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
