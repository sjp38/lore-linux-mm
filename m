Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC6D6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:49:56 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r101so27705561ioi.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:49:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id s75si1227849ios.102.2016.12.01.10.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:49:55 -0800 (PST)
Date: Thu, 1 Dec 2016 19:49:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161201184947.GR3045@worktop.programming.kicks-ass.net>
References: <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
 <20161201053035.GC3092@twins.programming.kicks-ass.net>
 <20161201124024.GB3924@linux.vnet.ibm.com>
 <20161201163614.GL3092@twins.programming.kicks-ass.net>
 <20161201165918.GG3924@linux.vnet.ibm.com>
 <20161201180953.GO3045@worktop.programming.kicks-ass.net>
 <20161201184252.GP3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201184252.GP3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Thu, Dec 01, 2016 at 10:42:52AM -0800, Paul E. McKenney wrote:
> On Thu, Dec 01, 2016 at 07:09:53PM +0100, Peter Zijlstra wrote:
> > Thing is, I'm slightly uncomfortable with de-coupling rcu-sched from
> > actual schedule() calls.
> 
> OK, what is the source of your discomfort?

Good question; after a little thought its not much different from other
cases. So let me ponder this a bit more..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
