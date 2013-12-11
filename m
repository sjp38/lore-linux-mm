Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 53B666B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 10:21:58 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so3010645eaj.1
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 07:21:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a9si19530905eew.75.2013.12.11.07.21.56
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 07:21:57 -0800 (PST)
Date: Wed, 11 Dec 2013 10:21:26 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] mm: numa: Guarantee that tlb_flush_pending updates are
 visible before page table updates
Message-ID: <20131211102126.532c763d@annuminas.surriel.com>
In-Reply-To: <20131211132109.GB24125@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
	<20131211132109.GB24125@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 11 Dec 2013 13:21:09 +0000
Mel Gorman <mgorman@suse.de> wrote:

> According to documentation on barriers, stores issued before a LOCK can
> complete after the lock implying that it's possible tlb_flush_pending can
> be visible after a page table update. As per revised documentation, this patch
> adds a smp_mb__before_spinlock to guarantee the correct ordering.

And now you have 18 patches :)
 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>
 
-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
