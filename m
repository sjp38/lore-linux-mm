Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAD356B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 11:44:30 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so46153680wjc.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 08:44:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n128si3750715wmf.141.2016.12.02.08.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 08:44:29 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB2GiPbN060479
	for <linux-mm@kvack.org>; Fri, 2 Dec 2016 11:44:28 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2739nntvfj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Dec 2016 11:44:26 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 2 Dec 2016 09:44:08 -0700
Date: Fri, 2 Dec 2016 08:44:08 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
 <20161130174802.GM18432@dhcp22.suse.cz>
 <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
 <20161130182552.GN18432@dhcp22.suse.cz>
 <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
 <a21ba936-0b8e-fd8e-620e-933850cc992d@kernelpanic.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a21ba936-0b8e-fd8e-620e-933850cc992d@kernelpanic.ru>
Message-Id: <20161202164408.GM3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 02, 2016 at 07:39:24PM +0300, Boris Zhmurov wrote:
> Paul E. McKenney Thu Dec 01 2016 - 14:39:21 EST:
> 
> >> Well, I can confirm, that replacing cond_resched_rcu_qs in 
> >> shrink_node_memcg by cond_resched also makes dmesg clean from RCU 
> >> CPU stall warnings.
> >> 
> >> I've attached patch (just modification of Paul's patch), that
> >> fixes RCU stall messages in situations, when all memory is used by
> >>  couchbase/memcached + fs cache and linux starts to use swap.
> 
> > Nice! Just to double-check, could you please also test your patch
> > above with these two commits from -rcu?
> > 
> > d2db185bfee8 ("rcu: Remove short-term CPU kicking") f8f127e738e3
> > ("rcu: Add long-term CPU kicking")
> > 
> > Thanx, Paul
> 
> 
> Looks like patches d2db185bfee8 and f8f127e738e3 change nothing.
> 
> With cond_resched() in shrink_node_memcg and these two patches dmesg is
> clean. No any RCU CPU stall messages.

Very good!  I have these two patches queued for 4.11.

And thank you again for all the testing!!!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
