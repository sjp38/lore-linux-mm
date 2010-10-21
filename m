Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E73826B0088
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 22:48:06 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9L2m5dj003852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Oct 2010 11:48:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 37B8945DE51
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 11:48:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 175D945DE4F
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 11:48:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD671DB8017
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 11:48:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DB0B1DB8013
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 11:48:04 +0900 (JST)
Date: Thu, 21 Oct 2010 11:42:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2] nommu: add anonymous page memcg accounting
Message-Id: <20101021114240.8d27d39f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <WC20101021023516.32042E@digidescorp.com>
References: <1287491654-4005-1-git-send-email-steve@digidescorp.com>
	<20101019154819.GC15844@balbir.in.ibm.com>
	<1287512657.2500.31.camel@iscandar.digidescorp.com>
	<20101020091746.f0cc5dc2.kamezawa.hiroyu@jp.fujitsu.com>
	<1287578957.2603.34.camel@iscandar.digidescorp.com>
	<20101021090847.b4e23dde.kamezawa.hiroyu@jp.fujitsu.com>
	<WC20101021023516.32042E@digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Steve Magnani <steve@digidescorp.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 21:35:16 -0500
"Steve Magnani" <steve@digidescorp.com> wrote:

> On Thu, 2010-10-21 at 09:08 +0900, KAMEZAWA Hiroyuki wrote:
> > I myself can't maintain NOMMU kernel. So, please test every -rc1 when
> > this patch merged. OK ?
> 
> It's reasonable to ask that features be tested every so often, and since the memory cgroup code seems to be 
> changing relatively frequently it probably needs exercising more often. I can't commit to this, though - I 
> don't know how much longer I'll be working with NOMMU kernels, and they are notoriously fragile. Any memory 
> access bug that would cause an oops (or SEGV) in a "normal" kernel can cause subtle and almost impossible to 
> debug behavior on a NOMMU system. For this reason I always try to work with "stable" kernels (recent threads 
> debating the term notwithstanding)...so it would be a pretty far jump to a -rc1 kernel.
> 
> Is this a showstopper (in which case David's patch to make the CGROUP_MEM_RES_CTLR Kconfig option depend on MMU 
> should be implemented), or should I post V3 of the patch that has Balbir's suggested change? 
> 

I asked just because I'm curious and maintainance is always a concern.
But it's not showstopper.

BTW, my request is updating Documentaion as:
 
 1. Please clarify "When reaching limit, OOM-Kill is inoved."
 2. Add TODO List.
    For example)For NOMMU guys, you don't need page_cgroup->lru because no page reclaim happens.
    I think you can delete page_cgroup->lru and save much memmory.

I'll ack if v3 seems O.K. But I'm sorry it's in merge-window and people will be busy
for a while. please be patient.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
