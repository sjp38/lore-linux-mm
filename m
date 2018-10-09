Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6946B0007
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:04:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 17-v6so2361227pgs.18
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:04:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e62-v6si23845716pfe.31.2018.10.09.15.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 15:04:03 -0700 (PDT)
Date: Tue, 9 Oct 2018 15:04:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Message-Id: <20181009150401.c72cde05338c1ec80a4b8701@linux-foundation.org>
In-Reply-To: <20181009184732.762-4-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	<20181009184732.762-4-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue,  9 Oct 2018 14:47:32 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Make it easier to catch bugs in the shadow node shrinker by adding a
> counter for the shadow nodes in circulation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/vmstat.c            |  1 +
>  mm/workingset.c        | 12 ++++++++++--
>  3 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4179e67add3d..d82e80d82aa6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -161,6 +161,7 @@ enum node_stat_item {
>  	NR_SLAB_UNRECLAIMABLE,
>  	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
>  	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> +	WORKINGSET_NODES,

Documentation/admin-guide/cgroup-v2.rst, please.  And please check for
any other missing items while in there?
