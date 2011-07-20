Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D90D56B007E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 03:01:08 -0400 (EDT)
Date: Wed, 20 Jul 2011 09:01:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: change memcg_oom_mutex to spinlock
Message-ID: <20110720070105.GC10857@tiehlicka.suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
 <b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
 <20110720145553.7703dbcb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110720145553.7703dbcb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 20-07-11 14:55:53, KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Jul 2011 17:29:51 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > memcg_oom_mutex is used to protect memcg OOM path and eventfd interface
> > for oom_control. None of the critical sections which it protects sleep
> > (eventfd_signal works from atomic context and the rest are simple linked
> > list resp. oom_lock atomic operations).
> > Mutex is also too heavy weight for those code paths because it triggers
> > a lot of scheduling. It also makes makes convoying effects more visible
> > when we have a big number of oom killing because we take the lock
> > mutliple times during mem_cgroup_handle_oom so we have multiple places
> > where many processes can sleep.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

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
