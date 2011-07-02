Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7954E6B0012
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 23:04:57 -0400 (EDT)
Received: by iyl8 with SMTP id 8so4572796iyl.14
        for <linux-mm@kvack.org>; Fri, 01 Jul 2011 20:04:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308696090-31569-2-git-send-email-yinghan@google.com>
References: <1308696090-31569-1-git-send-email-yinghan@google.com>
	<1308696090-31569-2-git-send-email-yinghan@google.com>
Date: Sat, 2 Jul 2011 08:34:55 +0530
Message-ID: <BANLkTikxH-=2TxEiTvk6naO6aeLjgNZqOA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] Revert soft_limit reclaim changes under global pressure.
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, Jun 22, 2011 at 4:11 AM, Ying Han <yinghan@google.com> wrote:
> Two commits are reverted in this patch.
>
> memcg: count the soft_limit reclaim in global background reclaim
> memcg: add the soft_limit reclaim in global direct reclaim.
>
> The two patches are the changes on top of existing global soft_limit
> reclaim which will also be reverted in the following patch.
>

Why are we doing this? To make the patch series better to read or for
ease of code development? IOW, your changelog is not very clear on the
benefits

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
