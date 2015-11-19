Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1496B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 06:36:26 -0500 (EST)
Received: by wmec201 with SMTP id c201so20964984wme.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 03:36:25 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id r62si28656800wmg.24.2015.11.19.03.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 03:36:25 -0800 (PST)
Date: Thu, 19 Nov 2015 12:36:18 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/9] mm: introduce fault_env
Message-ID: <20151119113618.GN3816@twins.programming.kicks-ass.net>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1447889136-6928-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447889136-6928-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 19, 2015 at 01:25:29AM +0200, Kirill A. Shutemov wrote:
> The idea borrowed from Peter's patch from patchset on speculative page
> faults[1]:
> 
> Instead of passing around the endless list of function arguments,
> replace the lot with a single structure so we can change context
> without endless function signature changes.
> 
> The changes are mostly mechanical with exception of faultaround code:
> filemap_map_pages() got reworked a bit.
> 
> This patch is preparation for the next one.
> 
> [1] http://lkml.kernel.org/r/20141020222841.302891540@infradead.org
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>

Thanks for doing that!

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
