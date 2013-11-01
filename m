Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3016B0035
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 17:23:53 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so4363904pdj.22
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 14:23:53 -0700 (PDT)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id gj2si5771169pac.109.2013.11.01.14.23.51
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 14:23:52 -0700 (PDT)
Message-ID: <52741BE0.4070306@redhat.com>
Date: Fri, 01 Nov 2013 17:23:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cache largest vma
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/01/2013 04:17 PM, Davidlohr Bueso wrote:
> While caching the last used vma already does a nice job avoiding
> having to iterate the rbtree in find_vma, we can improve. After
> studying the hit rate on a load of workloads and environments,
> it was seen that it was around 45-50% - constant for a standard
> desktop system (gnome3 + evolution + firefox + a few xterms),
> and multiple java related workloads (including Hadoop/terasort),
> and aim7, which indicates it's better than the 35% value documented
> in the code.
> 
> By also caching the largest vma, that is, the one that contains
> most addresses, there is a steady 10-15% hit rate gain, putting
> it above the 60% region. This improvement comes at a very low

I suspect this will especially help when also using automatic
numa balancing, which causes periodic page faults.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
