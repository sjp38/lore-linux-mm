Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B0BB86B0098
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:51:35 -0500 (EST)
Date: Thu, 24 Nov 2011 10:51:24 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/8] mm: memcg: clean up fault accounting
Message-ID: <20111124095124.GG6843@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-4-git-send-email-hannes@cmpxchg.org>
 <20111124093349.GC26036@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124093349.GC26036@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 24, 2011 at 10:33:49AM +0100, Michal Hocko wrote:
> On Wed 23-11-11 16:42:26, Johannes Weiner wrote:
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > The fault accounting functions have a single, memcg-internal user, so
> > they don't need to be global.  In fact, their one-line bodies can be
> > directly folded into the caller.  
> 
> At first I thought that this doesn't help much because the generated
> code should be exactly same but thinking about it some more it makes
> sense.
> We should have a single place where we account for events. Maybe we
> should include also accounting done in mem_cgroup_charge_statistics
> (this would however mean that mem_cgroup_count_vm_event would have to be
> split). What do you think?

I'm all for unifying all the stats crap into a single place.
Optimally, we should have been able to put memcg hooks below
count_vm_event* but maybe that ship has sailed with PGPGIN/PGPGOUT
having different meanings between memcg and the rest of the system :/

Anything in that direction is improvement, IMO.

> > And since faults happen one at a time, use this_cpu_inc() directly
> > instead of this_cpu_add(foo, 1).
> 
> The generated code will be same but it is easier to read, so agreed.

And it fits within 80 columns :-)

> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Anyway
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
