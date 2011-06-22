Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B04CA900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:22:23 -0400 (EDT)
Date: Wed, 22 Jun 2011 17:22:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/7] export memory cgroup's swappines by
 mem_cgroup_swappiness()
Message-ID: <20110622152216.GG14343@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616125222.71bcdff3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616125222.71bcdff3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu 16-06-11 12:52:22, KAMEZAWA Hiroyuki wrote:
> From 6f9c40172947fb92ab0ea6f7d73d577473879636 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 15 Jun 2011 12:06:31 +0900
> Subject: [PATCH 2/7] export memory cgroup's swappines by mem_cgroup_swappiness()
> 
> Each memory cgroup has 'swappiness' value and it can be accessed by
> get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> and swappiness is passed by argument.
> 
> It's now static function but some planned updates will need to
> get swappiness from files other than memcontrol.c
> This patch exports get_swappiness() as mem_cgroup_swappiness().
> By this, we can remove the argument of swapiness from try_to_fre...
> 
> I think this makes sense because passed swapiness is always from memory
> cgroup passed as an argument and this duplication of argument is
> not very good.

Yes makes sense and it makes it more looking like a global reclaim.

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

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
