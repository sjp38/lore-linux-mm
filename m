Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6056B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 13:39:12 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u62so16692541lfg.6
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:39:12 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id o6si14954490lff.2.2017.06.03.10.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 10:39:10 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id f14so6771594lfe.1
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:39:10 -0700 (PDT)
Date: Sat, 3 Jun 2017 20:39:06 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 3/6] mm: memcontrol: use the node-native slab memory
 counters
Message-ID: <20170603173906.GC15130@esperanza>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530181724.27197-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, May 30, 2017 at 02:17:21PM -0400, Johannes Weiner wrote:
> Now that the slab counters are moved from the zone to the node level
> we can drop the private memcg node stats and use the official ones.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 2 --
>  mm/memcontrol.c            | 8 ++++----
>  mm/slab.h                  | 4 ++--
>  3 files changed, 6 insertions(+), 8 deletions(-)

Not sure if moving slab stats from zone to node is such a good idea,
because they may be useful for identifying the reason of OOM, especially
on 32 bit hosts, but provided the previous patch is accepted, this one
looks good to me.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
