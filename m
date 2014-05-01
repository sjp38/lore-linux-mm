Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1901D6B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 02:39:15 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so171420wib.6
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 23:39:14 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id fv7si356092wib.123.2014.04.30.23.39.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 23:39:13 -0700 (PDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so171403wib.6
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 23:39:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1404301744580.8415@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744580.8415@chino.kir.corp.google.com>
Date: Thu, 1 May 2014 15:39:12 +0900
Message-ID: <CAAmzW4Nj04rbdoe8dkA-r14j+5iStUxFLM5BEkTmgEB+tHtsUA@mail.gmail.com>
Subject: Re: [patch] mm, thp: do not perform sync compaction on pagefault
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

2014-05-01 9:45 GMT+09:00 David Rientjes <rientjes@google.com>:
> Synchronous memory compaction can be very expensive: it can iterate an enormous
> amount of memory without aborting and it can wait on page locks and writeback to
> complete if a pageblock cannot be defragmented.
> Unfortunately, it's too expensive for pagefault for transparent hugepages and
> it's much better to simply fallback to pages.  On 128GB machines, we find that
> synchronous memory compaction can take O(seconds) for a single thp fault.

Hello,

AFAIK, synchronous compaction doesn't wait the page on writeback.
sync compaction pass MIGRATE_SYNC_LIGHT for migrate_mode,
instead of MIGRATE_SYNC. It results in skipping the page on writeback.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
