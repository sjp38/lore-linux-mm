Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 427636B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 20:35:46 -0400 (EDT)
Message-ID: <51563336.701@huawei.com>
Date: Sat, 30 Mar 2013 08:35:02 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: take reference before releasing rcu_read_lock
References: <51556CE9.9060000@huawei.com> <5155718A.90108@parallels.com>
In-Reply-To: <5155718A.90108@parallels.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 2013/3/29 18:48, Glauber Costa wrote:
> On 03/29/2013 02:28 PM, Li Zefan wrote:
>> The memcg is not referenced, so it can be destroyed at anytime right
>> after we exit rcu read section, so it's not safe to access it.
>>
>> To fix this, we call css_tryget() to get a reference while we're still
>> in rcu read section.
>>
>> This also removes a bogus comment above __memcg_create_cache_enqueue().
>>
> Out of curiosity, did you see that happening ?
> 

Just by code inspection. This is not the only place you use RCU in this
wrong way. Remember the last patch I sent? ;)

> Theoretically, the race you describe seem real, and the fix is sound.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
