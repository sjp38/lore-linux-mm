Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 48B5A6B0037
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 04:57:43 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so3359871pbb.41
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 01:57:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id xv7si1555515pab.56.2013.11.15.01.57.40
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 01:57:41 -0800 (PST)
Date: Fri, 15 Nov 2013 09:57:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: hugetlbfs: Add some VM_BUG_ON()s to catch
 non-hugetlbfs pages
Message-ID: <20131115095731.GC26002@suse.de>
References: <20131114233357.90EE35C1@viggo.jf.intel.com>
 <20131114233358.2B10EA33@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131114233358.2B10EA33@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Nov 14, 2013 at 03:33:58PM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Dave Jiang reported that he was seeing oopses when running
> NUMA systems and default_hugepagesz=1G.  I traced the issue down
> to migrate_page_copy() trying to use the same code for hugetlb
> pages and transparent hugepages.  It should not have been trying
> to pass thp pages in there.
> 
> So, add some VM_BUG_ON()s for the next hapless VM developer that
> tries the same thing.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
