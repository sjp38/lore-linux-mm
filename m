Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f47.google.com (mail-vn0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 78EEC6B0038
	for <linux-mm@kvack.org>; Sun, 26 Apr 2015 22:50:48 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so10390729vnb.3
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 19:50:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ke9si27983417vdb.55.2015.04.26.19.50.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Apr 2015 19:50:47 -0700 (PDT)
Message-ID: <553DA3FF.3000304@redhat.com>
Date: Sun, 26 Apr 2015 22:50:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Defer flush of writable TLB entries
References: <1429983942-4308-1-git-send-email-mgorman@suse.de> <1429983942-4308-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1429983942-4308-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/25/2015 01:45 PM, Mel Gorman wrote:
> If a PTE is unmapped and it's dirty then it was writable recently. Due
> to deferred TLB flushing, it's best to assume a writable TLB cache entry
> exists. With that assumption, the TLB must be flushed before any IO can
> start or the page is freed to avoid lost writes or data corruption. This
> patch defers flushing of potentially writable TLBs as long as possible.
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
