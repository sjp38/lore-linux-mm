Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF506B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 15:59:53 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so266928pad.7
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 12:59:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qz9si2223329pab.152.2014.08.13.12.59.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Aug 2014 12:59:52 -0700 (PDT)
Date: Wed, 13 Aug 2014 12:59:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating
Message-Id: <20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
In-Reply-To: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org

On Wed, 13 Aug 2014 11:28:27 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Commit 67f87463d3 cleared the NUMA bit in a copy of the PMD entry, but
> then wrote back the original
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: <stable@vger.kernel.org>

What are the runtime effects of this patch?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
