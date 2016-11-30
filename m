Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A36B6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:12:57 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id g12so45397637lfe.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:12:57 -0800 (PST)
Received: from mail.setcomm.ru (mail.setcomm.ru. [2a00:1248:5004:5::3])
        by mx.google.com with ESMTP id v72si20143941lfa.287.2016.11.30.10.12.55
        for <linux-mm@kvack.org>;
        Wed, 30 Nov 2016 10:12:55 -0800 (PST)
Reply-To: bb@kernelpanic.ru
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
References: <20161124133019.GE3612@linux.vnet.ibm.com>
 <de88a72a-f861-b51f-9fb3-4265378702f1@kernelpanic.ru>
 <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
 <20161130174802.GM18432@dhcp22.suse.cz>
From: Boris Zhmurov <bb@kernelpanic.ru>
Message-ID: <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
Date: Wed, 30 Nov 2016 21:12:52 +0300
MIME-Version: 1.0
In-Reply-To: <20161130174802.GM18432@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

Michal Hocko 30/11/16 20:48:

>> Well, after some testing I may say, that your patch:
>> ---------------------8<-----------------------------------
>> commit 7cebc6b63bf75db48cb19a94564c39294fd40959
>> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>> Date:   Fri Nov 25 12:48:10 2016 -0800
>>
>>    mm: Prevent shrink_node_memcg() RCU CPU stall warnings
>> ---------------------8<-----------------------------------
>>
>> fixes stall warning and dmesg is clean now.
> 
> Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?

I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
I can try another portion of patches, no problem :)

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
