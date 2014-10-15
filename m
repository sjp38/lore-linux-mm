Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A0B616B006E
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 05:13:52 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id n3so1258120wiv.15
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 02:13:52 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id fr3si5429951wib.4.2014.10.15.02.13.50
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 02:13:51 -0700 (PDT)
Date: Wed, 15 Oct 2014 12:13:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: free compound page with correct order
Message-ID: <20141015091341.GB12538@node.dhcp.inet.fi>
References: <1413317800-25450-1-git-send-email-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413317800-25450-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 01:16:39PM -0700, Yu Zhao wrote:
> Compound page should be freed by put_page() or free_pages() with
> correct order. Not doing so with causing the tail pages leaked.
> 
> The compound order can be obtained by compound_order() or use
> HPAGE_PMD_ORDER in our case. Some people would argue the latter
> is faster but I prefer the former which is more general.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Urghh.. Sorry about that.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: 97ae17497e99 ("thp: implement refcounting for huge zero page")
Cc: stable@vger.kernel.org # v3.8+

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
