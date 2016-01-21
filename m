Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 876C86B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 17:52:41 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id e32so44859903qgf.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 14:52:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f99si3719478qge.21.2016.01.21.14.52.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 14:52:41 -0800 (PST)
Date: Thu, 21 Jan 2016 23:52:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Couple of fixes for deferred_split_huge_page()
Message-ID: <20160121225237.GH7119@redhat.com>
References: <20160121012237.GE7119@redhat.com>
 <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 21, 2016 at 03:09:20PM +0300, Kirill A. Shutemov wrote:
> Hi Andrea,
> 
> Sorry, I should be noticed and address the issue with scan before...
> 
> Patchset below should address your concern.
> 
> I've tested it in qemu with fake numa.

That was fast and already in -mm!

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Great thanks,
Andrea

> 
> Kirill A. Shutemov (3):
>   thp: make split_queue per-node
>   thp: change deferred_split_count() to return number of THP in queue
>   thp: limit number of object to scan on deferred_split_scan()
> 
>  include/linux/mmzone.h |  6 +++++
>  mm/huge_memory.c       | 64 +++++++++++++++++++++++++-------------------------
>  mm/page_alloc.c        |  5 ++++
>  3 files changed, 43 insertions(+), 32 deletions(-)
> 
> -- 
> 2.7.0.rc3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
