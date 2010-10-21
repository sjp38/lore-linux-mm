Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5686B0088
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 22:35:22 -0400 (EDT)
Received: from WorldClient by digidescorp.com (MDaemon PRO v10.1.1)
	with ESMTP id md50001456734.msg
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 21:35:20 -0500
Date: Wed, 20 Oct 2010 21:35:16 -0500
From: "Steve Magnani" <steve@digidescorp.com>
Subject: Re: [PATCH V2] nommu: add anonymous page memcg accounting
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Message-ID: <WC20101021023516.32042E@digidescorp.com>
In-Reply-To: <20101021090847.b4e23dde.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287491654-4005-1-git-send-email-steve@digidescorp.com> <20101019154819.GC15844@balbir.in.ibm.com> <1287512657.2500.31.camel@iscandar.digidescorp.com> <20101020091746.f0cc5dc2.kamezawa.hiroyu@jp.fujitsu.com> <1287578957.2603.34.camel@iscandar.digidescorp.com> <20101021090847.b4e23dde.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-10-21 at 09:08 +0900, KAMEZAWA Hiroyuki wrote:
> I myself can't maintain NOMMU kernel. So, please test every -rc1 when
> this patch merged. OK ?

It's reasonable to ask that features be tested every so often, and since the memory cgroup code seems to be 
changing relatively frequently it probably needs exercising more often. I can't commit to this, though - I 
don't know how much longer I'll be working with NOMMU kernels, and they are notoriously fragile. Any memory 
access bug that would cause an oops (or SEGV) in a "normal" kernel can cause subtle and almost impossible to 
debug behavior on a NOMMU system. For this reason I always try to work with "stable" kernels (recent threads 
debating the term notwithstanding)...so it would be a pretty far jump to a -rc1 kernel.

Is this a showstopper (in which case David's patch to make the CGROUP_MEM_RES_CTLR Kconfig option depend on MMU 
should be implemented), or should I post V3 of the patch that has Balbir's suggested change? 

Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
