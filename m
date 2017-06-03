Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 086EA6B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 13:41:00 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o139so21655135lfe.15
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:40:59 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id n78si3165865lfi.348.2017.06.03.10.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 10:40:58 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id x81so1361827lfb.3
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:40:58 -0700 (PDT)
Date: Sat, 3 Jun 2017 20:40:55 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 4/6] mm: memcontrol: use generic mod_memcg_page_state for
 kmem pages
Message-ID: <20170603174055.GD15130@esperanza>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-5-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530181724.27197-5-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, May 30, 2017 at 02:17:22PM -0400, Johannes Weiner wrote:
> The kmem-specific functions do the same thing. Switch and drop.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 17 -----------------
>  kernel/fork.c              |  8 ++++----
>  mm/slab.h                  | 16 ++++++++--------
>  3 files changed, 12 insertions(+), 29 deletions(-)

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
