Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 267CE6B2F68
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:35:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r69-v6so4424689pgr.13
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:35:34 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 90-v6si6644053pla.466.2018.08.24.04.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 04:35:33 -0700 (PDT)
Date: Fri, 24 Aug 2018 14:35:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v6 0/2] huge_pmd_unshare migration and flushing
Message-ID: <20180824113529.os4sx6ls5vbz4gwi@black.fi.intel.com>
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823205917.16297-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 23, 2018 at 08:59:15PM +0000, Mike Kravetz wrote:
> Correct a data corruption issue caused by improper handling of shared
> huge PMDs during page migration.  This issue was observed in a customer
> environment and can be recreated fairly easily with a test program.
> Patch 0001 addresses this issue only and is copied to stable with the
> intention that this will go to stable releases.  It has existed since
> the addition of shared huge PMD support.
> 
> While considering the issue above, Kirill Shutemov noticed that other
> callers of huge_pmd_unshare have potential issues with cache and TLB
> flushing.  A separate patch (0002) takes advantage of the new routine
> adjust_range_if_pmd_sharing_possible() to adjust flushing ranges in
> the cases where huge PMD sharing is possible.  There is no copy to
> stable for this patch as it has not been reported as an issue and
> discovered only via code inspection.

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
