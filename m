Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC00A6B025E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 16:24:17 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 34so247304520uac.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 13:24:17 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id f2si502217uaa.197.2016.12.01.13.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 13:24:16 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id x186so11578097vkd.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 13:24:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161201132156.21450-1-mhocko@kernel.org>
References: <20161201132156.21450-1-mhocko@kernel.org>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 2 Dec 2016 08:24:16 +1100
Message-ID: <CAKTCnzmZ1cwmtg+p3=3rTQJbf12VmFzWJcM+wsAdNN20v1DMDw@mail.gmail.com>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr in count_shadow_nodes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, =?UTF-8?Q?Marek_Marczykowski=2DG=C3=B3recki?= <marmarek@mimuw.edu.pl>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 2, 2016 at 12:21 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
> has made the workingset shadow nodes shrinker memcg aware. The
> implementation is not correct though because memcg_kmem_enabled() might
> become true while we are doing a global reclaim when the sc->memcg might
> be NULL which is exactly what Marek has seen:
>
<snip>
>
> -       if (memcg_kmem_enabled()) {
> +       if (sc->memcg) {
>                 pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
>                                                      LRU_ALL_FILE);
>         } else {

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
