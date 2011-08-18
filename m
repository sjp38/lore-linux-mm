Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 57D2F900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 01:56:56 -0400 (EDT)
Date: Thu, 18 Aug 2011 07:56:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] memcg: pin execution to current cpu while draining stock
Message-ID: <20110818055649.GA23056@tiehlicka.suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
 <2f17df54db6661c39a05669d08a9e6257435b898.1311338634.git.mhocko@suse.cz>
 <20110725101657.21f85bf0.kamezawa.hiroyu@jp.fujitsu.com>
 <20110817194927.GA10982@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110817194927.GA10982@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 17-08-11 21:49:27, Johannes Weiner wrote:
> Commit d1a05b6 'memcg: do not try to drain per-cpu caches without
> pages' added a drain_local_stock() call to a preemptible section.
> 
> The draining task looks up the cpu-local stock twice to set the
> draining-flag, then to drain the stock and clear the flag again.  If
> the task is migrated to a different CPU in between, noone will clear
> the flag on the first stock and it will be forever undrainable.  Its
> charge can not be recovered and the cgroup can not be deleted anymore.
> 
> Properly pin the task to the executing CPU while draining stocks.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com
> Cc: Michal Hocko <mhocko@suse.cz>

My fault, I didn't realize that drain_local_stock needs preemption
disabled. Sorry about that and good work, Johannes. 

Acked-by: Michal Hocko <mhocko@suse.cz>
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
