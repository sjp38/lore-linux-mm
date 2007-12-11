Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBB5aLPF004510
	for <linux-mm@kvack.org>; Tue, 11 Dec 2007 00:36:21 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBB5aLC0470168
	for <linux-mm@kvack.org>; Tue, 11 Dec 2007 00:36:21 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBB5aKkj005243
	for <linux-mm@kvack.org>; Tue, 11 Dec 2007 00:36:21 -0500
Message-ID: <475E21CC.7060408@linux.vnet.ibm.com>
Date: Tue, 11 Dec 2007 11:06:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] fix accounting in vmscan.c for memory controller
References: <20071211112644.221a8dc5.kamezawa.hiroyu@jp.fujitsu.com> <475E1CBC.4070408@linux.vnet.ibm.com> <20071211142911.4b8091d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071211142911.4b8091d2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 11 Dec 2007 10:44:36 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Looks good to me.
>>
>> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>>
>> TODO:
>>
>> 1. Should we have vm_events for the memory controller as well?
>>    May be in the longer term
>>
> 
> ALLOC_STALL is recoreded as failcnt, I think.
> I think DIRECT can be accoutned easily.

Thanks for clarifying

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
