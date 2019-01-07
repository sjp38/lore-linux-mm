Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13E3B8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 18:43:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id u17so971584pgn.17
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 15:43:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f10si6971089pgo.356.2019.01.07.15.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 15:43:56 -0800 (PST)
Date: Mon, 7 Jan 2019 15:43:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/25] Increase success rates and reduce latency of
 compaction v2
Message-Id: <20190107154354.b0805ca15767fc7ea9e37545@linux-foundation.org>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Fri,  4 Jan 2019 12:49:46 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> This series reduces scan rates and success rates of compaction, primarily
> by using the free lists to shorten scans, better controlling of skip
> information and whether multiple scanners can target the same block and
> capturing pageblocks before being stolen by parallel requests. The series
> is based on the 4.21/5.0 merge window after Andrew's tree had been merged.
> It's known to rebase cleanly.
> 
> ...
>
>  include/linux/compaction.h |    3 +-
>  include/linux/gfp.h        |    7 +-
>  include/linux/mmzone.h     |    2 +
>  include/linux/sched.h      |    4 +
>  kernel/sched/core.c        |    3 +
>  mm/compaction.c            | 1031 ++++++++++++++++++++++++++++++++++----------
>  mm/internal.h              |   23 +-
>  mm/migrate.c               |    2 +-
>  mm/page_alloc.c            |   70 ++-
>  9 files changed, 908 insertions(+), 237 deletions(-)

Boy that's a lot of material.  I just tossed it in there unread for
now.  Do you have any suggestions as to how we can move ahead with
getting this appropriately reviewed and tested?
