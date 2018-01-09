Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5B846B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 12:26:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so4698157pge.13
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 09:26:29 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30100.outbound.protection.outlook.com. [40.107.3.100])
        by mx.google.com with ESMTPS id k27si5461451pfh.225.2018.01.09.09.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 09:26:28 -0800 (PST)
Subject: Re: [PATCH v3 2/2] mm/memcg: Consolidate
 mem_cgroup_resize_[memsw]_limit() functions.
References: <20171220135329.GS4831@dhcp22.suse.cz>
 <20180109165815.8329-1-aryabinin@virtuozzo.com>
 <20180109165815.8329-2-aryabinin@virtuozzo.com>
 <CALvZod64eZGKne7jZip_O4_q4yjaRsVWpTRa0pQgRT3guqQkGA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6ba40354-10d8-7955-7932-9dcd05ed5977@virtuozzo.com>
Date: Tue, 9 Jan 2018 20:26:33 +0300
MIME-Version: 1.0
In-Reply-To: <CALvZod64eZGKne7jZip_O4_q4yjaRsVWpTRa0pQgRT3guqQkGA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On 01/09/2018 08:10 PM, Shakeel Butt wrote:
> On Tue, Jan 9, 2018 at 8:58 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() are almost
>> identical functions. Instead of having two of them, we could pass an
>> additional argument to mem_cgroup_resize_limit() and by using it,
>> consolidate all the code in a single function.
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> 
> I think this is already proposed and Acked.
> 
> https://patchwork.kernel.org/patch/10150719/
> 

Indeed. I'll rebase 1/2 patch on top, if it will be applied first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
