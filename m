Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 293EA6B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 19:58:45 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2333231qyk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 16:58:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305826360-2167-1-git-send-email-yinghan@google.com>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
Date: Fri, 20 May 2011 08:58:44 +0900
Message-ID: <BANLkTik2uUwJmWuwhmX_L1wRsQ0hbBzvsg@mail.gmail.com>
Subject: Re: [PATCH V3 1/3] memcg: rename mem_cgroup_zone_nr_pages() to mem_cgroup_zone_nr_lru_pages()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, May 20, 2011 at 2:32 AM, Ying Han <yinghan@google.com> wrote:
> The caller of the function has been renamed to zone_nr_lru_pages(), and this
> is just fixing up in the memcg code. The current name is easily to be mis-read
> as zone's total number of pages.
>
> This patch is based on mmotm-2011-05-06-16-39
>
> no change since v1.
>
> Signed-off-by: Ying Han <yinghan@google.com>
>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
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
