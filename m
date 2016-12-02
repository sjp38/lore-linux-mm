Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E62D06B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 11:39:28 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o141so111754386lff.7
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 08:39:28 -0800 (PST)
Received: from mail.setcomm.ru (mail.setcomm.ru. [2a00:1248:5004:5::3])
        by mx.google.com with ESMTP id o67si3080454lfi.80.2016.12.02.08.39.27
        for <linux-mm@kvack.org>;
        Fri, 02 Dec 2016 08:39:27 -0800 (PST)
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
 <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
From: Boris Zhmurov <bb@kernelpanic.ru>
Message-ID: <a21ba936-0b8e-fd8e-620e-933850cc992d@kernelpanic.ru>
Date: Fri, 2 Dec 2016 19:39:24 +0300
MIME-Version: 1.0
In-Reply-To: <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Paul E. McKenney Thu Dec 01 2016 - 14:39:21 EST:

>> Well, I can confirm, that replacing cond_resched_rcu_qs in 
>> shrink_node_memcg by cond_resched also makes dmesg clean from RCU 
>> CPU stall warnings.
>> 
>> I've attached patch (just modification of Paul's patch), that
>> fixes RCU stall messages in situations, when all memory is used by
>>  couchbase/memcached + fs cache and linux starts to use swap.

> Nice! Just to double-check, could you please also test your patch
> above with these two commits from -rcu?
> 
> d2db185bfee8 ("rcu: Remove short-term CPU kicking") f8f127e738e3
> ("rcu: Add long-term CPU kicking")
> 
> Thanx, Paul


Looks like patches d2db185bfee8 and f8f127e738e3 change nothing.

With cond_resched() in shrink_node_memcg and these two patches dmesg is
clean. No any RCU CPU stall messages.

Thanks.

-- 
Boris Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
