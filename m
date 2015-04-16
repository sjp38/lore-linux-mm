Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 054D26B0070
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 12:00:11 -0400 (EDT)
Received: by qcpm10 with SMTP id m10so8782200qcp.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 09:00:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j47si8652373qge.110.2015.04.16.09.00.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 09:00:09 -0700 (PDT)
Message-ID: <552FDC87.6040004@redhat.com>
Date: Thu, 16 Apr 2015 12:00:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm: Gather more PFNs before sending a TLB to flush
 unmapped pages
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1429179766-26711-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2015 06:22 AM, Mel Gorman wrote:
> The patch "mm: Send a single IPI to TLB flush multiple pages when unmapping"
> would batch 32 pages before sending an IPI. This patch increases the size of
> the data structure to hold a pages worth of PFNs before sending an IPI. This
> is a trade-off between memory usage and reducing IPIS sent. In the ideal
> case where multiple processes are reading large mapped files, this patch
> reduces interrupts/second from roughly 180K per second to 60K per second.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
