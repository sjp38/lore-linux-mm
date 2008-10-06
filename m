Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m96HQW2c019607
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 04:26:32 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m96HQMFD4169942
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 04:26:22 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m96HQMJv020472
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 04:26:22 +1100
Message-ID: <48EA4A3C.3030106@linux.vnet.ibm.com>
Date: Mon, 06 Oct 2008 22:56:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] memcg update v6 (for review and discuss)
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com> <20081002180229.5bb94727.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081002180229.5bb94727.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 1 Oct 2008 16:52:33 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> This series is update from v5.
>>
>> easy 4 patches are already posted as ready-to-go-series.
>>
>> This is need-more-discuss set.
>>
>> Includes following 6 patches. (reduced from v5).
>> The whole series are reordered.
>>
>> [1/6] make page_cgroup->flags to be atomic.
>> [2/6] allocate all page_cgroup at boot.
>> [3/6] rewrite charge path by charge/commit/cancel
>> [4/6] new force_empty and move_account
>> [5/6] lazy lru free
>> [6/6] lazy lru add.
>>
>> Patch [3/6] and [4/6] are totally rewritten.
>> Races in Patch [6/6] is fixed....I think.
>>
>> Patch [1-4] seems to be big but there is no complicated ops.
>> Patch [5-6] is more racy. Check-by-regression-test is necessary.
>> (Of course, I does some.)
>>
>> If ready-to-go-series goes, next is patch 1 and 2.
>>
> 
> No terrible bugs until now on my test.
> 
> My current idea for next week is following.
> (I may have to wait until the end of next merge window. If so, 
>  I'll wait and maintain this set.)
> 
>  - post ready-to-go set again.
>  - post 1/6 and 2/6 as may-ready-to-go set. I don't chagnge order of these.
>  - reflects comments for 3/6. 
>    patch 3/6 adds new functions. So, please tell me if you have better idea
>    about new functions.
>  - check logic for 4/6.
>  - 5/6 and 6/6 may need some more comments in codes.
>  - no new additional ones.

Kamezawa-San, Andrew,

I think patches 1 and 2 are ready to go. Andrew they remove the cgroup member
from struct page and will help reduce the overhead for distros that care about
32 bit systems and also help with performance (in my runs so far).

I would recommend pushing 1 and 2 right away to -mm followed by the other
performance improvements. Comments?


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
