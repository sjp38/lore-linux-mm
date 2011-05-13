Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BF4B76B0012
	for <linux-mm@kvack.org>; Thu, 12 May 2011 23:53:42 -0400 (EDT)
Received: by qyk2 with SMTP id 2so148770qyk.14
        for <linux-mm@kvack.org>; Thu, 12 May 2011 20:53:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 13 May 2011 12:53:40 +0900
Message-ID: <BANLkTinbMUsB_4Qn6OFEQBYJwFWza_N9eg@mail.gmail.com>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

On Fri, May 13, 2011 at 12:10 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> ZONE_CONGESTED should be a state of global memory reclaim.
> If not, a busy memcg sets this and give unnecessary throttoling in
> wait_iff_congested() against memory recalim in other contexts. This makes
> system performance bad.
>
> I'll think about "memcg is congested!" flag is required or not, later.
> But this fix is required 1st.

It's reasonable.

>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>





-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
