Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 20A836B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 02:27:07 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n8T6a26e027248
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:36:02 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8T6iccD590076
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:44:42 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8T6icFQ027964
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:44:38 +1000
Date: Tue, 29 Sep 2009 11:41:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] memcg: some modification to softlimit under
 hierarchical memory reclaim.
Message-ID: <20090929061132.GA498@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 15:01:41]:

> No major changes in this patch for 3 weeks.
> While testing, I found a few css->refcnt bug in softlimit.(and posted patches)
> But it seems no more (easy) ones.
>

Kamezawa-San, this worries me, could you please confirm if you are
able to see this behaviour without your patches applied as well? I am
doing some more stress tests on my side.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
