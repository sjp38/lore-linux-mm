Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAF7PMx8013892
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:25:22 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAF7QKpR3465258
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:26:20 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAF7Q82u028311
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:26:09 +1100
Message-ID: <491E795D.5070507@linux.vnet.ibm.com>
Date: Sat, 15 Nov 2008 12:55:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] memcg updates (14/Nov/2008)
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com> <20081115120015.22fa5720.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081115120015.22fa5720.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 14 Nov 2008 19:12:46 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> Several patches are posted after last update (12/Nov),
>> it's better to catch all up as series.
>>
>> All patchs are mm-of-the-moment snapshot 2008-11-13-17-22
>>   http://userweb.kernel.org/~akpm/mmotm/
>> (You may need to patch fs/dquota.c and fix kernel/auditsc.c CONFIG error)
>>
>> New ones are 1,2,3 and 9. 
>>
>> IMHO, patch 1-4 are ready to go. (but I want Ack from Balbir to 3/9)
>>
> Reduced CCs.
> 
> Hi folks, I noticed that all 9 pathces here are now in mmotm.
> Thank you for all your patient help! and
> please try "mm-of-the-moment snapshot 2008-11-14-17-14" 
> Now, mem+swap controller is available there.
> 
> My concern is architecture other than x86-64. It seems I and Nishimura use
> x86-64 in main test. So, test in other archtecuthre is very welcome.
> 
> I have no patches in my queue and wondering how to start
>   - shrink usage
>   - dirty ratio for memcg.
>   - help Balbir's hierarchy.
> works. (But I may have to clean up/optimize codes before going further.)
> 
> and Balbir, the world is changed after synchronized-LRU patch ([8/9]).
> please see it. 

Time to resynchronize the patches! I've taken a cursory look, not done a
detailed review of those patches. Help with hierarchy would be nice, I've got
most of the patches nailed down, except for resynchronization with mmotm.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
