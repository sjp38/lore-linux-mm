Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAEC82F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 16:25:07 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so268186302wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:25:07 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ec20si9838350wic.70.2015.09.24.13.25.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 13:25:06 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so128379327wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:25:05 -0700 (PDT)
Date: Thu, 24 Sep 2015 23:25:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/16] Refreshed page-flags patchset
Message-ID: <20150924202503.GA24381@node.dhcp.inet.fi>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1509241111590.21022@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1509241111590.21022@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 24, 2015 at 11:13:22AM -0500, Christoph Lameter wrote:
> On Thu, 24 Sep 2015, Kirill A. Shutemov wrote:
> 
> > As requested, here's reworked version of page-flags patchset.
> > Updated version should fit more naturally into current code base.
> 
> This is certainly great for specialized debugging hunting for improper
> handling of page flags for compound pages but a regular debug
> kernel will get a mass of VM_BUG_ON(s) at numerous page flag uses in the
> code. Is that really useful in general for a debug kernel?

As I said before, it was useful for me in few cases.

I can wrap these VM_BUG_ONs under separate config, if it helps.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
