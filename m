Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7ED6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 12:32:43 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id v6so8289614lbi.24
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 09:32:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a15si3615780lbh.86.2014.08.13.09.32.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 09:32:41 -0700 (PDT)
Date: Wed, 13 Aug 2014 17:32:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating
Message-ID: <20140813163237.GH7970@suse.de>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 13, 2014 at 11:28:27AM -0400, Matthew Wilcox wrote:
> Commit 67f87463d3 cleared the NUMA bit in a copy of the PMD entry, but
> then wrote back the original
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: <stable@vger.kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
