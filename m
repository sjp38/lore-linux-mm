Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 56D2D6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 11:57:19 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id k15so10144307qaq.41
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:57:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h108si3126471qgh.106.2014.08.13.08.57.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Aug 2014 08:57:18 -0700 (PDT)
Message-ID: <53EB8A93.4010908@redhat.com>
Date: Wed, 13 Aug 2014 11:56:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 08/13/2014 11:28 AM, Matthew Wilcox wrote:
> Commit 67f87463d3 cleared the NUMA bit in a copy of the PMD entry, but
> then wrote back the original
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: <stable@vger.kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
