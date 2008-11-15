Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAF9KP3m004107
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 14:50:25 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAF9KQZY3207194
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 14:50:26 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAF9KPeB003221
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 14:50:25 +0530
Message-ID: <491E942B.2080102@linux.vnet.ibm.com>
Date: Sat, 15 Nov 2008 14:49:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] memcg updates (14/Nov/2008)
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com> <20081115120015.22fa5720.kamezawa.hiroyu@jp.fujitsu.com> <491E795D.5070507@linux.vnet.ibm.com> <2754.10.75.179.61.1226740560.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <2754.10.75.179.61.1226740560.squirrel@webmail-b.css.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Balbir Singh said:
>> KAMEZAWA Hiroyuki wrote:
>> Time to resynchronize the patches! I've taken a cursory look, not done a
>> detailed review of those patches. Help with hierarchy would be nice, I've
>> got
>> most of the patches nailed down, except for resynchronization with mmotm.
>>
> I have no other patches now and I'd like to use time for testing and
> reviewing. So, it's nice time to resynchronize patches, yes.
> 
> Okay, let's start hierarchy support first. I'll stop "new feature" work
> for a while.

OKAY, let me post v4 and then we'll synchronize the patchset. I would like to
review/test as well after hierarchy and then implement soft limits. Soft limits
will allow us to over commit mem cgroup, which is a very useful feature.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
