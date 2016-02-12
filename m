Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 522776B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:33:40 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fl4so38605888pad.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:33:40 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id u10si21443075pfa.95.2016.02.12.10.33.39
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:33:39 -0800 (PST)
Subject: Re: [PATCHv2 13/28] thp: support file pages in zap_huge_pmd()
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-14-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE2581.6070901@intel.com>
Date: Fri, 12 Feb 2016 10:33:37 -0800
MIME-Version: 1.0
In-Reply-To: <1455200516-132137-14-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> For file pages we don't deposit page table on mapping: no need to
> withdraw it.

I thought the deposit thing was to guarantee we could always do a PMD
split.  It still seems like if you wanted to split a huge-tmpfs page,
you'd need to first split the PMD which might need the deposited one.

Why not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
