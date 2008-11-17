Received: by wf-out-1314.google.com with SMTP id 28so2851731wfc.11
        for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:32:27 -0800 (PST)
Message-ID: <2f11576a0811170932g7f70ab3ai57d03958514124e@mail.gmail.com>
Date: Tue, 18 Nov 2008 02:32:26 +0900
From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [PATCH] vmscan: fix get_scan_ratio comment
In-Reply-To: <4921A706.9030501@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081116204720.1b8cbe18.akpm@linux-foundation.org>
	 <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
	 <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
	 <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org>
	 <4921A1AF.1070909@redhat.com>
	 <alpine.LFD.2.00.0811170904160.3468@nehalem.linux-foundation.org>
	 <4921A706.9030501@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

2008/11/18 Rik van Riel <riel@redhat.com>:
>
> Fix the old comment on the scan ratio calculations.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> Index: linux-2.6.28-rc5/mm/vmscan.c
> ===================================================================
> --- linux-2.6.28-rc5.orig/mm/vmscan.c   2008-11-16 17:47:13.000000000 -0500
> +++ linux-2.6.28-rc5/mm/vmscan.c        2008-11-17 12:05:03.000000000 -0500
> @@ -1386,9 +1386,9 @@ static void get_scan_ratio(struct zone *
>        file_prio = 200 - sc->swappiness;
>
>        /*
> -        *                  anon       recent_rotated[0]
> -        * %anon = 100 * ----------- / ----------------- * IO cost
> -        *               anon + file      rotate_sum
> +        *         recent_scanned[anon]
> +        * %anon = -------------------- * sc->swappiness
> +        *         recent_rotated[anon]
>         */
>        ap = (anon_prio + 1) * (zone->recent_scanned[0] + 1);
>        ap /= zone->recent_rotated[0] + 1;

looks good to me, absolutely.
      Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
