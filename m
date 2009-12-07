Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 70BC26B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 21:24:01 -0500 (EST)
Received: by pxi41 with SMTP id 41so89729pxi.23
        for <linux-mm@kvack.org>; Sun, 06 Dec 2009 18:23:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <COL115-W12ECCA5335D3BFBB60D5829F900@phx.gbl>
References: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
	 <20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
	 <COL115-W12ECCA5335D3BFBB60D5829F900@phx.gbl>
Date: Mon, 7 Dec 2009 10:23:59 +0800
Message-ID: <cf18f8340912061823q76921a5fuc036514f25c734c9@mail.gmail.com>
Subject: Re: [PATCH] memcg: correct return value at mem_cgroup reclaim
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: d-nishimura@mtf.biglobe.ne.jp
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, lliubbo@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, 6 Dec 2009 22:30:46 +0900
Daisuke Nishimura wrote:
>
> hi,
>
> On Sun, 6 Dec 2009 18:16:14 +0800
> Liu bo wrote:
>
>>
>> In order to indicate reclaim has succeeded, mem_cgroup_hierarchical_reclaim() used to return 1.
>> Now the return value is without indicating whether reclaim has successded usage, so just return the total reclaimed pages don't plus 1.
>>
>> Signed-off-by: Liu Bo
>> ---
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 14593f5..51b6b3c 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -737,7 +737,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>> css_put(&victim->css);
>> total += ret;
>> if (mem_cgroup_check_under_limit(root_mem))
>> - return 1 + total;
>> + return total;
>> }
>> return total;
>> }
> What's the benefit of this change ?
> I can't find any benefit to bother changing current behavior.
>
en..I think there is just a little unnormal logic. The function
recliam total pages,
but return 1 + total to the caller. I am unclear why do this,it have
no benefit too.

Anyway,yes,there is no benifit of this change in current code.
Please just ignore this patch.

> P.S.
> You should run ./scripts/checkpatch.pl before sending your patch,
> and refer to Documentation/email-clients.txt and check your email client setting.
>

Sorry, I registered a gmail and hoping it will be ok! :-)
Thanks!
-- 
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
