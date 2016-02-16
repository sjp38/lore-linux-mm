Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 18F906B0253
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 05:08:44 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so102614340pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 02:08:44 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id n11si50225271pfa.190.2016.02.16.02.08.43
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 02:08:43 -0800 (PST)
Date: Tue, 16 Feb 2016 13:08:38 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 15/28] thp: handle file COW faults
Message-ID: <20160216100838.GD46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-16-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE2629.90001@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE2629.90001@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 10:36:25AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> > File COW for THP is handled on pte level: just split the pmd.
> 
> More changelog.  More comments, please.

Okay, I'll add more.

> We don't want to COW THP's because we'll waste memory?  A COW that we
> could handle with 4k, we would have to handle with 2M, and that's
> inefficient and high-latency?

All of above.i

It's not clear how benefitial THP file COW mappings. And it would require
some code to make them work.

I think at some point we can consider teaching khugepaged to collapse such
pages, but allocating huge on fault is probably overkill.

> Seems like a good idea to me.  It would just be nice to ensure every
> reviewer doesn't have to think their way through it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
