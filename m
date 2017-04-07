Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1E9C6B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 09:05:33 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b9so21330675qtg.4
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 06:05:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n41si4742893qtf.240.2017.04.07.06.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 06:05:32 -0700 (PDT)
Message-ID: <1491570329.8850.163.camel@redhat.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
From: Rik van Riel <riel@redhat.com>
Date: Fri, 07 Apr 2017 09:05:29 -0400
In-Reply-To: <20170407064901.25398-1-ying.huang@intel.com>
References: <20170407064901.25398-1-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

On Fri, 2017-04-07 at 14:49 +0800, Huang, Ying wrote:

> To solve the issue, the per-CPU buffer is sorted according to the
> swap
> device before freeing the swap entries.A A Test shows that the time
> spent by swapcache_free_entries() could be reduced after the patch.
> 
> Test the patch via measuring the run time of
> swap_cache_free_entries()
> during the exit phase of the applications use much swap space.A A The
> results shows that the average run time of swap_cache_free_entries()
> reduced about 20% after applying the patch.
> 
> Signed-off-by: Huang Ying <ying.huang@intel.com>
> Acked-by: Tim Chen <tim.c.chen@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
