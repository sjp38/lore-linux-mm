Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 23E0B900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:35:27 -0400 (EDT)
Date: Thu, 23 Jun 2011 15:35:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/7] memcg: calc NUMA node's weight for scan.
Message-ID: <20110623133524.GJ31593@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616125633.9b9fa703.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616125633.9b9fa703.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu 16-06-11 12:56:33, KAMEZAWA Hiroyuki wrote:
> From fb8aaa2c5f7fd99dfcb5d2ecb3c1226a58caafea Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 16 Jun 2011 10:05:46 +0900
> Subject: [PATCH 6/7] memcg: calc NUMA node's weight for scan.
> 
> Now, by commit 889976, numa node scan of memcg is in round-robin.
> As commit log says, "a better algorithm is needed".
> 
> for implementing some good scheduling, one of required things is
> defining importance of each node at LRU scanning.
> 
> This patch defines each node's weight for scan as
> 
> swappiness = (memcg's swappiness)? memcg's swappiness : 1
> FILE = inactive_file + (inactive_file_is_low)? active_file : 0
> ANON = inactive_anon + (inactive_anon_is_low)? active_anon : 0
> 
> weight = (FILE * (200-swappiness) + ANON * swappiness)/200.

Shouldn't we consider the node size?
If we have a node which is almost full with file cache and then other
node wich is much bigger and it is mostly occupied by anonymous memory
than the other node might end up with higher weight.

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
