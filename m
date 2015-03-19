Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 03B5B6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 14:29:56 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so83681938pdn.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 11:29:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kk7si4379727pab.156.2015.03.19.11.29.54
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 11:29:55 -0700 (PDT)
Message-ID: <550B15A0.9090308@intel.com>
Date: Thu, 19 Mar 2015 11:29:52 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags
 on compound pages
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2015 10:08 AM, Kirill A. Shutemov wrote:
> The odd expection is PG_dirty: sound uses compound pages and maps them
> with PTEs. NO_COMPOUND triggers VM_BUG_ON() in set_page_dirty() on
> handling shared fault. Let's use HEAD for PG_dirty.

Can we get the sound guys to look at this, btw?  It seems like an odd
thing that we probably don't want to keep around, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
