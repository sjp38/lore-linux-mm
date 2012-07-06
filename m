Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1A3746B0070
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 01:06:00 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 23:05:59 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 96257C40003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 05:05:25 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6654sKt296084
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 23:05:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6654bLm011083
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 23:04:38 -0600
Date: Fri, 6 Jul 2012 13:04:30 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memcg: swappiness should between 0 and 100
Message-ID: <20120706050430.GA27704@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341550312-6815-1-git-send-email-liwp.linux@gmail.com>
 <20120706050013.GA15372@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120706050013.GA15372@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Wanpeng Li <liwp.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 06, 2012 at 01:00:13PM +0800, Gavin Shan wrote:
>On Fri, Jul 06, 2012 at 12:51:52PM +0800, Wanpeng Li wrote:
>>From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>>
>>Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>>---
>> mm/memcontrol.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>index 5e4d1ab..69a7d45 100644
>>--- a/mm/memcontrol.c
>>+++ b/mm/memcontrol.c
>>@@ -4176,7 +4176,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>
>It seems that we don't have the function in mainline.
>
>shangw@shangw:~/sandbox/linux/mm$ grep mem_cgroup_swappiness_write -r .
>shangw@shangw:~/sandbox/linux/mm$ 
>

Please ignore that cause my git tree has some problems and everything
in linux/mm has been cleared :-)

Thanks,
Gavin

>Thanks,
>Gavin
>
>> 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>> 	struct mem_cgroup *parent;
>>
>>-	if (val > 100)
>>+	if (val > 100 || val < 0)
>> 		return -EINVAL;
>>
>> 	if (cgrp->parent == NULL)
>>-- 
>>1.7.5.4
>>
>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
