Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 47C706B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 04:27:20 -0400 (EDT)
Date: Thu, 19 May 2011 10:26:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2 1/2] memcg: rename mem_cgroup_zone_nr_pages() to
 mem_cgroup_zone_nr_lru_pages()
Message-ID: <20110519082642.GD16531@cmpxchg.org>
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1305766511-11469-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, May 18, 2011 at 05:55:10PM -0700, Ying Han wrote:
> The caller of the function has been renamed to zone_nr_lru_pages(), and this
> is just fixing up in the memcg code. The current name is easily to be mis-read
> as zone's total number of pages.
> 
> This patch is based on mmotm-2011-05-06-16-39
> 
> no change on this patch from v1.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
