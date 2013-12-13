Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 86F1B6B00B3
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 10:47:06 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so974767eak.39
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 07:47:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 5si2311284eei.207.2013.12.13.07.47.05
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 07:47:05 -0800 (PST)
Message-ID: <52AB2BEE.8040303@redhat.com>
Date: Fri, 13 Dec 2013 10:46:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] mm: page_alloc: Break out zone page aging distribution
 into its own helper
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <1386943807-29601-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 09:10 AM, Mel Gorman wrote:
> This patch moves the decision on whether to round-robin allocations between
> zones and nodes into its own helper functions. It'll make some later patches
> easier to understand and it will be automatically inlined.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
