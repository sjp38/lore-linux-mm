Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56B786B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 06:52:52 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id q8so43264801lfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 03:52:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si31248277wmq.96.2016.04.14.03.52.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 03:52:50 -0700 (PDT)
Date: Thu, 14 Apr 2016 11:52:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Disable DEFERRED_STRUCT_PAGE_INIT on !NO_BOOTMEM
Message-ID: <20160414105243.GC27534@suse.de>
References: <1460602170-5821-1-git-send-email-gwshan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1460602170-5821-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, zhlcindy@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com

On Thu, Apr 14, 2016 at 12:49:30PM +1000, Gavin Shan wrote:
> When we have !NO_BOOTMEM, the deferred page struct initialization
> doesn't work well because the pages reserved in bootmem are released
> to the page allocator uncoditionally. It causes memory corruption
> and system crash eventually.
> 
> As Mel suggested, the bootmem is retiring slowly. We fix the issue
> by simply hiding DEFERRED_STRUCT_PAGE_INIT when bootmem is enabled.
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
