Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA896B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 12:32:18 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n81GWDDg019043
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 22:02:13 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n81GWBV82900054
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 22:02:13 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n81GWAP9031851
	for <linux-mm@kvack.org>; Wed, 2 Sep 2009 02:32:11 +1000
Date: Tue, 1 Sep 2009 22:01:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-ID: <20090901163152.GC5022@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090831102640.092092954@intel.com>
 <20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com>
 <20090901022514.GA11974@localhost>
 <20090901113214.60e7ae32.kamezawa.hiroyu@jp.fujitsu.com>
 <20090901064652.GA20342@localhost>
 <20090901161228.9fb33234.kamezawa.hiroyu@jp.fujitsu.com>
 <20090901085549.GA4454@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090901085549.GA4454@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Wu Fengguang <fengguang.wu@intel.com> [2009-09-01 16:55:49]:

> > My point is that memcg can show 'owner' of pages but the page may
> > be shared with something important task _and_ if a task is migrated,
> > its pages' memcg information is not updated now. Then, you can kill
> > a task which is not in memcg.
> 
> Ah thanks! I'm not aware of that tricky fact, and it does make a
> very good reason not to use memcg, although I guess locked page won't
> be migrated.
>

I think what Kamezawa-San is pointing to is that the task can migrate,
leaving behind the page in the memcg and poisioning those pages can
kill a task outside the memcg. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
