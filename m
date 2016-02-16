Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 15A456B0256
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 05:14:57 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fy10so61513957pac.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 02:14:57 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id g74si50322285pfd.215.2016.02.16.02.14.54
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 02:14:54 -0800 (PST)
Date: Tue, 16 Feb 2016 13:14:50 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 17/28] thp: skip file huge pmd on copy_huge_pmd()
Message-ID: <20160216101450.GE46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-18-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE2781.7060808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE2781.7060808@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 10:42:09AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> > File pmds can be safely skip on copy_huge_pmd(), we can re-fault them
> > later. COW for file mappings handled on pte level.
> 
> Is this different from 4k pages?  I figured we might skip copying
> file-backed ptes on fork, but I couldn't find the code.

Currently, we only filter out on per-VMA basis. See first comment in
copy_page_range().

Here we handle PMD mapped file pages in COW mapping. File THP can be
mapped into COW mapping as result of read page fault.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
