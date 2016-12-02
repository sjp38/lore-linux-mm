Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 50AF76B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 08:52:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so168732967pgc.2
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 05:52:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q127si5258908pfb.189.2016.12.02.05.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 05:52:19 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB2DnjSY131328
	for <linux-mm@kvack.org>; Fri, 2 Dec 2016 08:52:18 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2737vwywm0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Dec 2016 08:52:17 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 2 Dec 2016 06:52:16 -0700
Date: Fri, 2 Dec 2016 05:52:16 -0800
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
 <20161202093734.GE6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202093734.GE6830@dhcp22.suse.cz>
Message-Id: <20161202135216.GJ3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Boris Zhmurov <bb@kernelpanic.ru>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 02, 2016 at 10:37:35AM +0100, Michal Hocko wrote:
> On Thu 01-12-16 21:10:01, Boris Zhmurov wrote:
> > Michal Hocko 30/11/16 21:25:
> > 
> > >>> Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?
> > >>
> > >> I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
> > >> I can try another portion of patches, no problem :)
> > > 
> > > Replacing cond_resched_rcu_qs in shrink_node_memcg by cond_resched would
> > > be really helpful to tell whether we are missing a real scheduling point
> > > or whether something more serious is going on here.
> > 
> > Well, I can confirm, that replacing cond_resched_rcu_qs in
> > shrink_node_memcg by cond_resched also makes dmesg clean from RCU CPU
> > stall warnings.
> > 
> > I've attached patch (just modification of Paul's patch), that fixes RCU
> > stall messages in situations, when all memory is used by
> > couchbase/memcached + fs cache and linux starts to use swap.
> 
> OK, thanks for the confirmation! I will send a patch because it is true
> that we do not have any scheduling point if no pages can be isolated
> fromm the LRU. This might be what you are seeing.

Thank you both!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
