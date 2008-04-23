Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3N36sP1010302
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 08:36:54 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3N36nB91138904
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 08:36:49 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3N372fY008147
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 03:07:02 GMT
Message-ID: <480EA6DE.8060307@linux.vnet.ibm.com>
Date: Wed, 23 Apr 2008 08:32:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: remove redundant initialization in mem_cgroup_create()
References: <480E9E52.4080905@cn.fujitsu.com> <20080423115041.c918091d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080423115041.c918091d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Apr 2008 10:26:26 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> *mem has been zeroed, that means mem->info has already
>> been filled with 0.
>>
> maybe my mistake :(
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

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
