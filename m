Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 28CC36B004A
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 19:21:26 -0500 (EST)
Date: Mon, 5 Mar 2012 09:17:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: fix mapcount check in move charge code for
 anonymous page
Message-Id: <20120305091719.c9f93f1a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1330720508-21019-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1330720508-21019-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

Hi, Horiguchi-san.

On Fri,  2 Mar 2012 15:35:08 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently charge on shared anonyous pages is supposed not to moved
> in task migration. To implement this, we need to check that mapcount > 1,
> instread of > 2. So this patch fixes it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
> index b6d1bab..785f6d3 100644
> --- linux-next-20120228.orig/mm/memcontrol.c
> +++ linux-next-20120228/mm/memcontrol.c
> @@ -5102,7 +5102,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>  		return NULL;
>  	if (PageAnon(page)) {
>  		/* we don't move shared anon */
> -		if (!move_anon() || page_mapcount(page) > 2)
> +		if (!move_anon() || page_mapcount(page) > 1)
>  			return NULL;
>  	} else if (!move_file())
>  		/* we ignore mapcount for file pages */
> -- 
> 1.7.7.6
> 
Sorry, it's my fault..
Thank you for catching this.

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
