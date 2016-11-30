Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF816B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:42:49 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so43745061pgx.6
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:42:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w4si65599467pfw.83.2016.11.30.11.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 11:42:48 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUJekvW089345
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:42:47 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2724mn1kab-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:42:47 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 12:42:47 -0700
Date: Wed, 30 Nov 2016 11:42:44 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
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
Message-Id: <20161130194244.GG3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

On Wed, Nov 30, 2016 at 09:12:52PM +0300, Boris Zhmurov wrote:
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

OK, I will keep the above patch and drop the shrink_node() patch.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
