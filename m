Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m563ggEI026536
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 09:12:42 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m563gRVE1495244
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 09:12:27 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m563gfBg025197
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 09:12:41 +0530
Message-ID: <4848B1DA.3060906@linux.vnet.ibm.com>
Date: Fri, 06 Jun 2008 09:11:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/3 v2] per-task-delay-accounting: add memory reclaim
 delay
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp> <48489E71.2060708@linux.vnet.ibm.com> <20080605202132.d84b7083.kobayashi.kk@ncos.nec.co.jp>
In-Reply-To: <20080605202132.d84b7083.kobayashi.kk@ncos.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Keika Kobayashi wrote:
> On Fri, 06 Jun 2008 07:48:25 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>>     $ ./delayget -d -p <pid>
>>>     CPU             count     real total  virtual total    delay total
>>>                      2640     2456153500     2478353004       28366219
>>>     IO              count    delay total
>>>                      2628    19894214188
>>>     SWAP            count    delay total
>>>                         0              0
>>>     RECLAIM         count    delay total
>>>                      6600    10682486085
>>>
>> Looks interesting, this data is for the whole system or memcgroup? If it is for
>> memcgroup, we should be using cgroupstats.
> 
> Thanks for your comment.
> This accounting, which is named "RECLAIM", is global and memcgroup reclaim delay
> and this data is value per task.
> 
> Unfortunately, I'm not sure what the whole system means.
> Could you tell me your point?

By whole system, I meant global reclaim.

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
