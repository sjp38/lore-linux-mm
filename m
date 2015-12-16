Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 530386B0265
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 07:00:07 -0500 (EST)
Received: by mail-lf0-f49.google.com with SMTP id z124so22642858lfa.3
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 04:00:07 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id p14si3457595lfd.159.2015.12.16.04.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 04:00:05 -0800 (PST)
Received: by mail-lb0-x230.google.com with SMTP id kw15so24049470lbb.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 04:00:05 -0800 (PST)
Date: Wed, 16 Dec 2015 14:00:02 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 6/9] rmap: support file THP
Message-ID: <20151216120002.GA17677@node.shutemov.name>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1447889136-6928-7-git-send-email-kirill.shutemov@linux.intel.com>
 <565E096D.7000105@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565E096D.7000105@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 01, 2015 at 12:56:13PM -0800, Dave Hansen wrote:
> On 11/18/2015 03:25 PM, Kirill A. Shutemov wrote:
> > -void page_add_file_rmap(struct page *page)
> > +void page_add_file_rmap(struct page *page, bool compound)
> 
> I take it we have to pass 'compound' in explicitly because
> PageCompound() could be true, but we don't want to do a compound
> mapping.  This is true for those weirdo sound driver allocations and a
> few other ones, right?

Right. Also more common case will be PTE-mapped THPs as we have now for
anon-THP.

Basically, we mirror what was done for anon rmap interface.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
