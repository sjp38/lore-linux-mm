Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 239776008DF
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 03:46:24 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7O7VWxn032651
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 03:31:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7O7kLfF089842
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 03:46:22 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7O7kKdR018517
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 01:46:21 -0600
Date: Tue, 24 Aug 2010 13:16:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: towards I/O aware memcg v5
Message-ID: <20100824074617.GI4684@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-20 18:55:52]:

> This is v5.
> 
> Sorry for delaying...but I had time for resetting myself and..several
> changes are added. I think this version is simpler than v4.
> 
> Major changes from v4 is 
>  a) added kernel/cgroup.c hooks again. (for b)
>  b) make RCU aware. previous version seems dangerous in an extreme case.
> 
> Then, codes are updated. Most of changes are related to RCU.
> 
> Patch brief view:
>  1. add hooks to kernel/cgroup.c for ID management.
>  2. use ID-array in memcg.
>  3. record ID to page_cgroup rather than pointer.
>  4. make update_file_mapped to be RCU aware routine instead of spinlock.
>  5. make update_file_mapped as general-purpose function.
>

Thanks for being persistent, will review the patches with comments in
the relevant patches. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
