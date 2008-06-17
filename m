Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5HAEvud027985
	for <linux-mm@kvack.org>; Tue, 17 Jun 2008 15:44:57 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5HAEdlR1413280
	for <linux-mm@kvack.org>; Tue, 17 Jun 2008 15:44:39 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5HAEtdW022268
	for <linux-mm@kvack.org>; Tue, 17 Jun 2008 15:44:56 +0530
Message-ID: <48578E9D.4050903@linux.vnet.ibm.com>
Date: Tue, 17 Jun 2008 15:44:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: reduce usage at change limit
References: <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com> <20080617123604.c8cb1bd5.kamezawa.hiroyu@jp.fujitsu.com> <48573397.608@linux.vnet.ibm.com> <20080617130656.bcd3ca85.kamezawa.hiroyu@jp.fujitsu.com> <20080617190055.2b55ba0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080617190055.2b55ba0b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

>> I'll repost later, today.
>>
> I'll postpone this until -mm is settled ;)
> 

Sure, by -mm is settled you mean scalable page reclaim, fast GUP and lockless
read size for pagecache? Is there something else I am unaware of?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
