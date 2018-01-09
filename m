Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29A4F6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 12:10:15 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 194so6253124wmv.9
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 09:10:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13sor6723348wre.28.2018.01.09.09.10.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 09:10:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180109165815.8329-2-aryabinin@virtuozzo.com>
References: <20171220135329.GS4831@dhcp22.suse.cz> <20180109165815.8329-1-aryabinin@virtuozzo.com>
 <20180109165815.8329-2-aryabinin@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 9 Jan 2018 09:10:12 -0800
Message-ID: <CALvZod64eZGKne7jZip_O4_q4yjaRsVWpTRa0pQgRT3guqQkGA@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm/memcg: Consolidate mem_cgroup_resize_[memsw]_limit()
 functions.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 9, 2018 at 8:58 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() are almost
> identical functions. Instead of having two of them, we could pass an
> additional argument to mem_cgroup_resize_limit() and by using it,
> consolidate all the code in a single function.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

I think this is already proposed and Acked.

https://patchwork.kernel.org/patch/10150719/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
