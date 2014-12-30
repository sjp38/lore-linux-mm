Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 209F76B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 00:00:42 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so18642518pdj.28
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 21:00:41 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id cp9si56154136pad.184.2014.12.29.21.00.39
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 21:00:40 -0800 (PST)
Date: Tue, 30 Dec 2014 14:00:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] CMA: Add cma_alloc_counter to make cma_alloc work
 better if it meet busy range
Message-ID: <20141230050038.GD4588@js1304-P5Q-DELUXE>
References: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
 <1419500608-11656-4-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419500608-11656-4-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: m.szyprowski@samsung.com, mina86@mina86.com, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, pintu.k@samsung.com, weijie.yang@samsung.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, laurent.pinchart+renesas@ideasonboard.com, rientjes@google.com, sasha.levin@oracle.com, liuweixing@xiaomi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Thu, Dec 25, 2014 at 05:43:28PM +0800, Hui Zhu wrote:
> In [1], Joonsoo said that cma_alloc_counter is useless because pageblock
> is isolated.
> But if alloc_contig_range meet a busy range, it will undo_isolate_page_range
> before goto try next range. At this time, __rmqueue_cma can begin allocd
> CMA memory from the range.

Is there any real issue from this?
When failed, we will quickly re-isolate pageblock for adjacent page
so there is no big problem I guess.

If there is real issue, how about doing start_isolation/undo_isolation
in cma_alloc()? It would reduce useless do/undo isolation due to
failed trial.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
