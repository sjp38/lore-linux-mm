Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 63FB86B0037
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 16:38:38 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so4742880pbb.17
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 13:38:37 -0700 (PDT)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id mi5si5682993pab.193.2013.11.01.13.38.36
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 13:38:37 -0700 (PDT)
Received: by mail-qe0-f53.google.com with SMTP id cy11so2879973qeb.26
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 13:38:35 -0700 (PDT)
Message-ID: <5274114B.7010302@gmail.com>
Date: Fri, 01 Nov 2013 16:38:35 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cache largest vma
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(11/1/13 4:17 PM), Davidlohr Bueso wrote:
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
> overhead for a miss. Furthermore, systems with !CONFIG_MMU keep
> the current logic.

I'm slightly surprised this cache makes 15% hit. Which application
get a benefit? You listed a lot of applications, but I'm not sure
which is highly depending on largest vma.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
