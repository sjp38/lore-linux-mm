Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF196B039F
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:38:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b9so43616677qtg.4
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:38:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u26si13330298qte.73.2017.04.10.05.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 05:38:27 -0700 (PDT)
Message-ID: <1491827904.8850.178.camel@redhat.com>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
From: Rik van Riel <riel@redhat.com>
Date: Mon, 10 Apr 2017 08:38:24 -0400
In-Reply-To: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2017-04-10 at 10:48 +0100, Mel Gorman wrote:
> 
> While this could be fixed with heavy locking, it's only necessary to
> make a copy of the PMD on the stack during change_pmd_range and avoid
> races. A new helper is created for this as the check if quite subtle
> and the
> existing similar helpful is not suitable. This passed 154 hours of
> testing
> (usually triggers between 20 minutes and 24 hours) without detecting
> bad
> PMDs or corruption. A basic test of an autonuma-intensive workload
> showed
> no significant change in behaviour.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Cc: stable@vger.kernel.org

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
