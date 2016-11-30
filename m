Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1F06B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:25:55 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jb2so34062948wjb.6
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:25:55 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id m141si8258196wmd.20.2016.11.30.10.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 10:25:54 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id jb2so23476640wjb.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:25:54 -0800 (PST)
Date: Wed, 30 Nov 2016 19:25:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161130182552.GN18432@dhcp22.suse.cz>
References: <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
 <20161130174802.GM18432@dhcp22.suse.cz>
 <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: paulmck@linux.vnet.ibm.com, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

On Wed 30-11-16 21:12:52, Boris Zhmurov wrote:
> Michal Hocko 30/11/16 20:48:
> 
> >> Well, after some testing I may say, that your patch:
> >> ---------------------8<-----------------------------------
> >> commit 7cebc6b63bf75db48cb19a94564c39294fd40959
> >> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >> Date:   Fri Nov 25 12:48:10 2016 -0800
> >>
> >>    mm: Prevent shrink_node_memcg() RCU CPU stall warnings
> >> ---------------------8<-----------------------------------
> >>
> >> fixes stall warning and dmesg is clean now.
> > 
> > Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?
> 
> I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
> I can try another portion of patches, no problem :)

Replacing cond_resched_rcu_qs in shrink_node_memcg by cond_resched would
be really helpful to tell whether we are missing a real scheduling point
or whether something more serious is going on here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
