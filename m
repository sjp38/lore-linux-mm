Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8936B006E
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 11:52:41 -0400 (EDT)
Received: by qku63 with SMTP id 63so135445156qku.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 08:52:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d68si8639273qhc.84.2015.04.16.08.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 08:52:40 -0700 (PDT)
Message-ID: <552FDABC.3060705@redhat.com>
Date: Thu, 16 Apr 2015 11:52:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1429179766-26711-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2015 06:22 AM, Mel Gorman wrote:

> 	If a clean page is unmapped and not immediately flushed, the
> 	architecture must guarantee that a write to that page from a CPU
> 	with a cached TLB entry will trap a page fault.
> 
> This is essentially what the kernel already depends on but the window is
> much larger with this patch applied and is worth highlighting.

> Signed-off-by: Mel Gorman <mgorman@suse.de>

Given the architectural guarantee ...

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
