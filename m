Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85F4E6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 06:44:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n104so11050068wrb.20
        for <linux-mm@kvack.org>; Mon, 01 May 2017 03:44:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 36si13369518edo.263.2017.05.01.03.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 03:44:50 -0700 (PDT)
Date: Mon, 1 May 2017 12:44:30 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170501104430.GA16306@cmpxchg.org>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-2-ying.huang@intel.com>
 <20170427053141.GA1925@bbox>
 <87mvb21fz1.fsf@yhuang-dev.intel.com>
 <20170428084044.GB19510@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170428084044.GB19510@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

On Fri, Apr 28, 2017 at 05:40:44PM +0900, Minchan Kim wrote:
> However, get_swap_page is ugly now. The caller should take care of
> failure and should retry after split. I hope get_swap_page includes
> split and retry logic in itself without reling on the caller.

I think this makes the interface terrible. It's an allocation function
to which you pass a reference object for size - and if the allocation
doesn't succeed it'll split your reference object to make it fit?

That's a nasty side effect for this function to have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
