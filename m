Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E87B46B0106
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 08:20:37 -0400 (EDT)
Date: Wed, 29 Jun 2011 14:20:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-ID: <20110629122034.GA24262@tiehlicka.suse.cz>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

On Wed 29-06-11 19:03:25, KAMEZAWA Hiroyuki wrote:
> This is onto 3 patches I posted yesterday.
> I'm sorry I once got Acks in v1 but refleshed totally. 
> ==
> From fda72071ee473be1caee163920da0f5c397c95e8 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 29 Jun 2011 18:24:49 +0900
> Subject: [PATCH] export memory cgroup's swappines
> 
> Each memory cgroup has 'swappiness' value and it can be accessed by
> get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> and swappiness is passed by argument. It's propagated by scan_control.
> 
> get_swappiness is static function but some planned updates will need to
> get swappiness from files other than memcontrol.c
> This patch exports get_swappiness() as mem_cgroup_swappiness().
> By this, we can remove the argument of swapiness from try_to_free...
> and drop swappiness from scan_control. only memcg uses it.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> 
> Changelog:
>   - drop swappiness from scan_control

Yes, this is even better.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
