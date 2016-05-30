Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A12806B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:28:41 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so266355185oiw.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:28:41 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id r16si24380316ign.98.2016.05.30.02.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:28:41 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id k76so6136383ita.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:28:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160530085311.GM22928@dhcp22.suse.cz>
References: <1464597951-2976-1-git-send-email-wwtao0320@163.com>
	<20160530085311.GM22928@dhcp22.suse.cz>
Date: Mon, 30 May 2016 17:28:40 +0800
Message-ID: <CACygaLCupPNRMWUpRe3WSCHWtAFH3MYKzppbjaX3As6EKKnVQQ@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol.c: add memory allocation result check
From: Wenwei Tao <ww.tao0320@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wenwei Tao <wwtao0320@163.com>, hannes@cmpxchg.org, vdavydov@virtuozzo.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I think explicit BUG_ON may make the debug easier, since it can point
out the wrong line.

2016-05-30 16:53 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> On Mon 30-05-16 16:45:51, Wenwei Tao wrote:
>> From: Wenwei Tao <ww.tao0320@gmail.com>
>>
>> The mem_cgroup_tree_per_node allocation might fail,
>> check that before continue the memcg init. Since it
>> is in the init phase, trigger the panic if that failure
>> happens.
>
> We would blow up in the very same function so what is the point of the
> explicit BUG_ON?
>
>> Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
>> ---
>>  mm/memcontrol.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 925b431..6385c62 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -5712,6 +5712,7 @@ static int __init mem_cgroup_init(void)
>>
>>               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
>>                                   node_online(node) ? node : NUMA_NO_NODE);
>> +             BUG_ON(!rtpn);
>>
>>               for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>>                       struct mem_cgroup_tree_per_zone *rtpz;
>> --
>> 1.8.3.1
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
