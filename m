Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE516B0253
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 05:00:28 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so102497236pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 02:00:28 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id h6si8395943pfd.5.2016.02.16.02.00.27
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 02:00:27 -0800 (PST)
Date: Tue, 16 Feb 2016 13:00:23 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 13/28] thp: support file pages in zap_huge_pmd()
Message-ID: <20160216100023.GC46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-14-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE2581.6070901@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE2581.6070901@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 10:33:37AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> > For file pages we don't deposit page table on mapping: no need to
> > withdraw it.
> 
> I thought the deposit thing was to guarantee we could always do a PMD
> split.  It still seems like if you wanted to split a huge-tmpfs page,
> you'd need to first split the PMD which might need the deposited one.
> 
> Why not?

For file thp, split_huge_pmd() is implemented by clearing out the pmd: we
can setup and fill pte table later. Therefore no need to deposit page
table -- we would not use it. DAX does the same.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
