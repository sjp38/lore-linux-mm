Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA5E98D003B
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 21:36:06 -0500 (EST)
Received: by iwc10 with SMTP id 10so822173iwc.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 18:36:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297248275-23521-1-git-send-email-hannes@cmpxchg.org>
References: <1297248275-23521-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 10 Feb 2011 11:36:02 +0900
Message-ID: <AANLkTimJcJaUWSuJYu-u7n2Ep1JWLC08XO0NECriX67A@mail.gmail.com>
Subject: Re: [patch] memcg: charged pages always have valid per-memcg zone info
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 9, 2011 at 7:44 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> page_cgroup_zoneinfo() will never return NULL for a charged page,
> remove the check for it in mem_cgroup_get_reclaim_stat_from_page().
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
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
