Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2426B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 13:54:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o139so21679273lfe.15
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:54:14 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id f134si1048641lff.157.2017.06.03.10.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 10:54:13 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id u62so6583764lfg.0
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:54:12 -0700 (PDT)
Date: Sat, 3 Jun 2017 20:54:10 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 6/6] mm: memcontrol: account slab stats per lruvec
Message-ID: <20170603175410.GF15130@esperanza>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530181724.27197-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, May 30, 2017 at 02:17:24PM -0400, Johannes Weiner wrote:
> Josef's redesign of the balancing between slab caches and the page
> cache requires slab cache statistics at the lruvec level.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/slab.c | 12 ++++--------
>  mm/slab.h | 18 +-----------------
>  mm/slub.c |  4 ++--
>  3 files changed, 7 insertions(+), 27 deletions(-)

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
