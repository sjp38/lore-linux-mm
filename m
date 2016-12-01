Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17A0B280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:36:19 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r94so20738651ioe.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:36:19 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id u125si9767051itd.17.2016.12.01.08.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:36:18 -0800 (PST)
Date: Thu, 1 Dec 2016 17:36:14 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161201163614.GL3092@twins.programming.kicks-ass.net>
References: <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
 <20161201053035.GC3092@twins.programming.kicks-ass.net>
 <20161201124024.GB3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201124024.GB3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Thu, Dec 01, 2016 at 04:40:24AM -0800, Paul E. McKenney wrote:
> On Thu, Dec 01, 2016 at 06:30:35AM +0100, Peter Zijlstra wrote:

> > Sure, we all dislike IPIs, but I'm thinking this half-way point is
> > sensible, no point in issuing user visible annoyance if indeed we can
> > prod things back to life, no?
> > 
> > Only if we utterly fail to make it respond should we bug the user with
> > our failure..
> 
> Sold!  ;-)
> 
> I will put together a patch later today.
> 
> My intent is to hold off on the "upgrade cond_resched()" patch, one
> step at a time.  Longer term, I do very much like the idea of having
> cond_resched() do both scheduling and RCU quiescent states, assuming
> that this avoids performance pitfalls.

Well, with the above change cond_resched() is already sufficient, no?

In fact, by doing the IPI thing we get the entire cond_resched*()
family, and we could add the should_resched() guard to
cond_resched_rcu().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
