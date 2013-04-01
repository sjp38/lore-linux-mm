Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8D0456B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 05:29:44 -0400 (EDT)
Message-ID: <515953AE.3000403@parallels.com>
Date: Mon, 1 Apr 2013 13:30:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: implement boost mode
References: <1364801670-10241-1-git-send-email-glommer@parallels.com> <51595311.7070509@jp.fujitsu.com>
In-Reply-To: <51595311.7070509@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>

On 04/01/2013 01:27 PM, Kamezawa Hiroyuki wrote:
> (2013/04/01 16:34), Glauber Costa wrote:
>> There are scenarios in which we would like our programs to run faster.
>> It is a hassle, when they are contained in memcg, that some of its
>> allocations will fail and start triggering reclaim. This is not good
>> for the program, that will now be slower.
>>
>> This patch implements boost mode for memcg. It exposes a u64 file
>> "memcg boost". Every time you write anything to it, it will reduce the
>> counters by ~20 %. Note that we don't want to actually reclaim pages,
>> which would defeat the very goal of boost mode. We just make the
>> res_counters able to accomodate more.
>>
>> This file is also available in the root cgroup. But with a slightly
>> different effect. Writing to it will make more memory physically
>> available so our programs can profit.
>>
>> Please ack and apply.
>>
> Nack.
> 
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
> 
> Please update limit temporary. If you need call-shrink-explicitly-by-user, 
> I think you can add it.
> 

I don't want to shrink memory because that will make applications
slower. I want them to be faster, so they need to have more memory.
There is solid research backing up my approach:
http://www.dilbert.com/fast/2008-05-08/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
