Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 161F26B0274
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:24:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so52209299wme.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:24:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l66si8051503wml.44.2016.11.30.09.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 09:23:59 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUHNg8Q039759
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:23:58 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2722bs2xu4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:23:58 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 10:23:57 -0700
Date: Wed, 30 Nov 2016 09:23:55 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130170557.GK18432@dhcp22.suse.cz>
Message-Id: <20161130172355.GA3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed, Nov 30, 2016 at 06:05:57PM +0100, Michal Hocko wrote:
> On Wed 30-11-16 17:38:20, Peter Zijlstra wrote:
> > On Wed, Nov 30, 2016 at 06:29:55AM -0800, Paul E. McKenney wrote:
> > > We can, and you are correct that cond_resched() does not unconditionally
> > > supply RCU quiescent states, and never has.  Last time I tried to add
> > > cond_resched_rcu_qs() semantics to cond_resched(), I got told "no",
> > > but perhaps it is time to try again.
> > 
> > Well, you got told: "ARRGH my benchmark goes all regress", or something
> > along those lines. Didn't we recently dig out those commits for some
> > reason or other?
> > 
> > Finding out what benchmark that was and running it against this patch
> > would make sense.
> > 
> > Also, I seem to have missed, why are we going through this again?
> 
> Well, the point I've brought that up is because having basically two
> APIs for cond_resched is more than confusing. Basically all longer in
> kernel loops do cond_resched() but it seems that this will not help the
> silence RCU lockup detector in rare cases where nothing really wants to
> schedule. I am really not sure whether we want to sprinkle
> cond_resched_rcu_qs at random places just to silence RCU detector...

Just in case there is any doubt on this point, any patch of mine adding
cond_resched_rcu_qs() functionality to cond_resched() cannot go upstream
without Peter's Acked-by.

Or did you have some other solution in mind?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
