Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9177F6B009D
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 03:32:17 -0500 (EST)
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <1236151414.5330.6692.camel@laptop>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
	 <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie>
	 <1235647139.16552.34.camel@penberg-laptop>
	 <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr>
	 <20090302112122.GC21145@csn.ul.ie>  <1236132307.2567.25.camel@ymzhang>
	 <1236151414.5330.6692.camel@laptop>
Content-Type: text/plain
Date: Wed, 04 Mar 2009 16:31:51 +0800
Message-Id: <1236155511.2567.41.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-03-04 at 08:23 +0100, Peter Zijlstra wrote:
> On Wed, 2009-03-04 at 10:05 +0800, Zhang, Yanmin wrote:
> > FAIR_GROUP_SCHED is a feature to support configurable cpu weight for different users.
> > We did find it takes lots of time to check/update the share weight which might create
> > lots of cache ping-pang. With sysbench(oltp)+mysql, that becomes more severe because
> > mysql runs as user mysql and sysbench runs as another regular user. When starting
> > the testing with 1 thread in command line, there are 2 mysql threads and 1 sysbench
> > thread are proactive.
> 
> cgroup based group scheduling doesn't bother with users. So unless you
> create sched-cgroups your should all be in the same (root) group.

I disable CGROUP, but enable GROUP_SCHED and USER_SCHED. My config inherits from old config
files.

CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set

I check defconfig on x86-64 of 2.6.28 and it does enable CGROUP and disable USER_SCHED.

Perhaps I need change my latest config file to the default on sched options.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
