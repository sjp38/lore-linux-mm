Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id B8F1B6B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 17:46:22 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] memcg: revert fix to mapcount check for this release
Date: Fri,  9 Mar 2012 17:46:11 -0500
Message-Id: <1331333171-27972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <alpine.LSU.2.00.1203091335020.19372@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 09, 2012 at 01:37:32PM -0800, Hugh Dickins wrote:
> Respectfully revert commit e6ca7b89dc76 "memcg: fix mapcount check
> in move charge code for anonymous page" for the 3.3 release, so that
> it behaves exactly like releases 2.6.35 through 3.2 in this respect.
> 
> Horiguchi-san's commit is correct in itself, 1 makes much more sense
> than 2 in that check; but it does not go far enough - swapcount
> should be considered too - if we really want such a check at all.

Agreed. We should rethink whole design rather than detail.

> We appear to have reached agreement now, and expect that 3.4 will
> remove the mapcount check, but had better not make 3.3 different.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 3.3-rc6+/mm/memcontrol.c	2012-03-05 22:03:45.940000832 -0800
> +++ linux/mm/memcontrol.c	2012-03-09 13:06:41.716250093 -0800
> @@ -5075,7 +5075,7 @@ static struct page *mc_handle_present_pt
>  		return NULL;
>  	if (PageAnon(page)) {
>  		/* we don't move shared anon */
> -		if (!move_anon() || page_mapcount(page) > 1)
> +		if (!move_anon() || page_mapcount(page) > 2)
>  			return NULL;
>  	} else if (!move_file())
>  		/* we ignore mapcount for file pages */
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
