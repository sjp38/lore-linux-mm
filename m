Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8987C6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 18:26:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h20so1413480wrf.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 15:26:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s18si11355251wrf.380.2018.01.09.15.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 15:26:26 -0800 (PST)
Date: Tue, 9 Jan 2018 15:26:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] mm/memcg: Consolidate
 mem_cgroup_resize_[memsw]_limit() functions.
Message-Id: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
In-Reply-To: <6ba40354-10d8-7955-7932-9dcd05ed5977@virtuozzo.com>
References: <20171220135329.GS4831@dhcp22.suse.cz>
	<20180109165815.8329-1-aryabinin@virtuozzo.com>
	<20180109165815.8329-2-aryabinin@virtuozzo.com>
	<CALvZod64eZGKne7jZip_O4_q4yjaRsVWpTRa0pQgRT3guqQkGA@mail.gmail.com>
	<6ba40354-10d8-7955-7932-9dcd05ed5977@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Tue, 9 Jan 2018 20:26:33 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> On 01/09/2018 08:10 PM, Shakeel Butt wrote:
> > On Tue, Jan 9, 2018 at 8:58 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> >> mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() are almost
> >> identical functions. Instead of having two of them, we could pass an
> >> additional argument to mem_cgroup_resize_limit() and by using it,
> >> consolidate all the code in a single function.
> >>
> >> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > 
> > I think this is already proposed and Acked.
> > 
> > https://patchwork.kernel.org/patch/10150719/
> > 
> 
> Indeed. I'll rebase 1/2 patch on top, if it will be applied first.

Yes please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
