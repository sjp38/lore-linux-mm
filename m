Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBF06B0260
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:41:25 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id g12so45057398lfe.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:41:25 -0800 (PST)
Received: from mail.setcomm.ru (mail.setcomm.ru. [81.211.32.179])
        by mx.google.com with ESMTP id e9si32240722lji.62.2016.11.30.09.41.23
        for <linux-mm@kvack.org>;
        Wed, 30 Nov 2016 09:41:23 -0800 (PST)
Reply-To: bb@kernelpanic.ru
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
References: <d6981bac-8e97-b482-98c0-40949db03ca3@kernelpanic.ru>
 <20161124133019.GE3612@linux.vnet.ibm.com>
 <de88a72a-f861-b51f-9fb3-4265378702f1@kernelpanic.ru>
 <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
From: Boris Zhmurov <bb@kernelpanic.ru>
Message-ID: <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
Date: Wed, 30 Nov 2016 20:41:20 +0300
MIME-Version: 1.0
In-Reply-To: <20161128150509.GG3924@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

Paul E. McKenney 28/11/16 18:05:

>>>> So Paul, I've dropped "mm: Prevent shrink_node_memcg() RCU CPU stall
>>>> warnings" patch, and stalls got back (attached).
>>>>
>>>> With this patch "commit 7cebc6b63bf75db48cb19a94564c39294fd40959" from
>>>> your tree stalls gone. Looks like that.
>>>
>>> So with only this commit and no other commit or configuration adjustment,
>>> everything works?  Or it the solution this commit and some other stuff?
>>>
>>> The reason I ask is that if just this commit does the trick, I should
>>> drop the others.
>>
>> I'd like to ask for some more time to make sure this is it.
>> Approximately 2 or 3 days.
> 
> Works for me!


Well, after some testing I may say, that your patch:
---------------------8<-----------------------------------
commit 7cebc6b63bf75db48cb19a94564c39294fd40959
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Fri Nov 25 12:48:10 2016 -0800

   mm: Prevent shrink_node_memcg() RCU CPU stall warnings
---------------------8<-----------------------------------

fixes stall warning and dmesg is clean now.

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
