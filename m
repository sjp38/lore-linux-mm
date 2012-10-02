Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A38386B00C7
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 05:19:20 -0400 (EDT)
Message-ID: <506AB0BF.9030400@parallels.com>
Date: Tue, 2 Oct 2012 13:15:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] memcg: provide root figures from system totals
References: <1348563173-8952-1-git-send-email-glommer@parallels.com> <1348563173-8952-2-git-send-email-glommer@parallels.com> <20121001170046.GC24860@dhcp22.suse.cz>
In-Reply-To: <20121001170046.GC24860@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On 10/01/2012 09:00 PM, Michal Hocko wrote:
> On Tue 25-09-12 12:52:50, Glauber Costa wrote:
>> > For the root memcg, there is no need to rely on the res_counters.
> This is true only if there are no children groups but once there is at
> least one we have to move global statistics into root res_counter and
> start using it since then. This is a tricky part because it has to be
> done atomically so that we do not miss anything.
> 
Why can't we shortcut it all the time?

It makes a lot of sense to use the root cgroup as the sum of everything,
IOW, global counters. Otherwise you are left in a situation where you
had global statistics, and all of a sudden, when a group is created, you
start having just a subset of that, excluding the tasks in root.

If we can always assume root will have the sum of *all* tasks, including
the ones in root, we should never need to rely on root res_counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
