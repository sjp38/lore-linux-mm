Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3672E6B0269
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:48:05 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id jb2so33888790wjb.6
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:48:05 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id w15si8109065wmw.89.2016.11.30.09.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 09:48:04 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id kp2so23354124wjc.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:48:03 -0800 (PST)
Date: Wed, 30 Nov 2016 18:48:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161130174802.GM18432@dhcp22.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: paulmck@linux.vnet.ibm.com, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

On Wed 30-11-16 20:41:20, Boris Zhmurov wrote:
> Paul E. McKenney 28/11/16 18:05:
> 
> >>>> So Paul, I've dropped "mm: Prevent shrink_node_memcg() RCU CPU stall
> >>>> warnings" patch, and stalls got back (attached).
> >>>>
> >>>> With this patch "commit 7cebc6b63bf75db48cb19a94564c39294fd40959" from
> >>>> your tree stalls gone. Looks like that.
> >>>
> >>> So with only this commit and no other commit or configuration adjustment,
> >>> everything works?  Or it the solution this commit and some other stuff?
> >>>
> >>> The reason I ask is that if just this commit does the trick, I should
> >>> drop the others.
> >>
> >> I'd like to ask for some more time to make sure this is it.
> >> Approximately 2 or 3 days.
> > 
> > Works for me!
> 
> 
> Well, after some testing I may say, that your patch:
> ---------------------8<-----------------------------------
> commit 7cebc6b63bf75db48cb19a94564c39294fd40959
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Fri Nov 25 12:48:10 2016 -0800
> 
>    mm: Prevent shrink_node_memcg() RCU CPU stall warnings
> ---------------------8<-----------------------------------
> 
> fixes stall warning and dmesg is clean now.

Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
