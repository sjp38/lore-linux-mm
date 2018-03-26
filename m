Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 163FD6B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:30:36 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b7-v6so4969912plr.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:30:36 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0130.outbound.protection.outlook.com. [104.47.0.130])
        by mx.google.com with ESMTPS id m63-v6si8766316pld.52.2018.03.26.08.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 08:30:34 -0700 (PDT)
Subject: Re: [PATCH 06/10] list_lru: Pass dst_memcg argument to
 memcg_drain_list_lru_node()
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163853059.21546.940468208501917585.stgit@localhost.localdomain>
 <20180324193253.y653nm4z6sh7u2kd@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0fe02df4-3d55-2ee3-95af-156ac63f29be@virtuozzo.com>
Date: Mon, 26 Mar 2018 18:30:26 +0300
MIME-Version: 1.0
In-Reply-To: <20180324193253.y653nm4z6sh7u2kd@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On 24.03.2018 22:32, Vladimir Davydov wrote:
> On Wed, Mar 21, 2018 at 04:22:10PM +0300, Kirill Tkhai wrote:
>> This is just refactoring to allow next patches to have
>> dst_memcg pointer in memcg_drain_list_lru_node().
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  include/linux/list_lru.h |    2 +-
>>  mm/list_lru.c            |   11 ++++++-----
>>  mm/memcontrol.c          |    2 +-
>>  3 files changed, 8 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>> index ce1d010cd3fa..50cf8c61c609 100644
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -66,7 +66,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
>>  #define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
>>  
>>  int memcg_update_all_list_lrus(int num_memcgs);
>> -void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
>> +void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg);
> 
> Please, for consistency pass the source cgroup as a pointer as well.

Ok
