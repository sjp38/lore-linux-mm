Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 521EC6B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:26:29 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id l68so85883740lfb.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:26:29 -0800 (PST)
Received: from mail.setcomm.ru (mail.setcomm.ru. [81.211.32.179])
        by mx.google.com with ESMTP id p142si32266182lfp.32.2016.11.30.10.26.28
        for <linux-mm@kvack.org>;
        Wed, 30 Nov 2016 10:26:28 -0800 (PST)
Reply-To: bb@kernelpanic.ru
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
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
 <20161130182552.GN18432@dhcp22.suse.cz>
From: Boris Zhmurov <bb@kernelpanic.ru>
Message-ID: <e4ee5c83-b127-adc7-ac7a-843a3d5ad8f9@kernelpanic.ru>
Date: Wed, 30 Nov 2016 21:26:26 +0300
MIME-Version: 1.0
In-Reply-To: <20161130182552.GN18432@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

Michal Hocko 30/11/16 21:25:
>> I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
>> I can try another portion of patches, no problem :)
> 
> Replacing cond_resched_rcu_qs in shrink_node_memcg by cond_resched would
> be really helpful to tell whether we are missing a real scheduling point
> or whether something more serious is going on here.

Ok, I'll try that.


-- 
Boris Zhmurov
System/Network Administrator
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
