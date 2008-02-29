Date: Fri, 29 Feb 2008 00:05:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: trivial clean up to zlc_setup
Message-Id: <20080229000544.5cf2667e.akpm@linux-foundation.org>
In-Reply-To: <20080229151057.66ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080229151057.66ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008 15:19:39 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> I found very small bug during review mel's 2 zonelist patch series.
> 
> this patch is trivial clean up.
> jiffies subtraction may cause overflow problem.
> it shold be used time_after().
> 
> Thanks.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> CC: Paul Jackson <pj@sgi.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c   2008-02-18 17:17:25.000000000 +0900
> +++ b/mm/page_alloc.c   2008-02-29 15:17:03.000000000 +0900
> @@ -1294,7 +1294,7 @@ static nodemask_t *zlc_setup(struct zone
>         if (!zlc)
>                 return NULL;
> 
> -       if (jiffies - zlc->last_full_zap > 1 * HZ) {
> +       if (time_after(jiffies, zlc->last_full_zap + HZ)) {
>                 bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
>                 zlc->last_full_zap = jiffies;
>         }

That's a mainline bug.  Also present in 2.6.24, maybe earlier.

But it's a minor one - we'll fix it up one second later (yes?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
