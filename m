Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5944E6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 15:56:17 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so16927659pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 12:56:17 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id wj8si19228490pab.47.2015.12.01.12.56.16
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 12:56:16 -0800 (PST)
Subject: Re: [PATCH 6/9] rmap: support file THP
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1447889136-6928-7-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <565E096D.7000105@intel.com>
Date: Tue, 1 Dec 2015 12:56:13 -0800
MIME-Version: 1.0
In-Reply-To: <1447889136-6928-7-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/18/2015 03:25 PM, Kirill A. Shutemov wrote:
> -void page_add_file_rmap(struct page *page)
> +void page_add_file_rmap(struct page *page, bool compound)

I take it we have to pass 'compound' in explicitly because
PageCompound() could be true, but we don't want to do a compound
mapping.  This is true for those weirdo sound driver allocations and a
few other ones, right?

Or is there something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
