Message-ID: <47B6A928.7000309@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 11:13:12 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 7/8] slub: Adjust order boundaries and minimum objects
 per slab.
References: <20080215230811.635628223@sgi.com> <20080215230854.643455255@sgi.com>
In-Reply-To: <20080215230854.643455255@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Christoph Lameter wrote:
> Since there is now no worry anymore about higher order allocs (hopefully)
> increase the minimum of objects per slab to 60 so that slub can reach a
> similar fastpath/slowpath ratio as slab. Set the max order to default to
> 6 (256k).
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/slub.c |   24 ++++--------------------
>  1 file changed, 4 insertions(+), 20 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-02-15 14:16:15.383080863 -0800
> +++ linux-2.6/mm/slub.c	2008-02-15 14:16:20.947052929 -0800
> @@ -156,24 +156,8 @@ static inline void ClearSlabDebug(struct
> +#define DEFAULT_MAX_ORDER 6
> +#define DEFAULT_MIN_OBJECTS 60

These look quite excessive from memory usage point of view. I saw you 
dropping DEFAULT_MAX_ORDER to 4 but it seems a lot for embedded guys, at 
least?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
