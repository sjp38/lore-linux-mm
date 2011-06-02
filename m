Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1446B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 09:30:51 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1467596bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 06:30:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-7-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-7-git-send-email-hannes@cmpxchg.org>
Date: Thu, 2 Jun 2011 22:30:48 +0900
Message-ID: <BANLkTi=x_Fm-AcwcRAicJ4BaK1z0tT0u+Q@mail.gmail.com>
Subject: Re: [patch 6/8] vmscan: change zone_nr_lru_pages to take memcg
 instead of scan control
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> This function only uses sc->mem_cgroup from the scan control. =A0Change
> it to take a memcg argument directly, so callsites without an actual
> reclaim context can use it as well.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I wonder this can be cut out and cab be merged immediately, no ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
