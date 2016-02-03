Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id CA84482963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:53:11 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so21551384pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:53:11 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id c8si11981001pat.62.2016.02.03.14.53.11
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 14:53:11 -0800 (PST)
Date: Thu, 4 Feb 2016 01:53:04 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
Message-ID: <20160203225304.GB22605@black.fi.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454512459-94334-5-git-send-email-kirill.shutemov@linux.intel.com>
 <56B21FC9.9040009@intel.com>
 <20160203144316.f01573516f186071bb2cf1bf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203144316.f01573516f186071bb2cf1bf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 03, 2016 at 02:43:16PM -0800, Andrew Morton wrote:
> On Wed, 3 Feb 2016 07:42:01 -0800 Dave Hansen <dave.hansen@intel.com> wrote:
> 
> > On 02/03/2016 07:14 AM, Kirill A. Shutemov wrote:
> > > But the new variant is somewhat slower. Current helpers iterates over
> > > VMAs the compound page is mapped to, and then over ptes within this VMA.
> > > New helpers iterates over small page, then over VMA the small page
> > > mapped to, and only then find relevant pte.
> > 
> > The code simplification here is really attractive.  Can you quantify
> > what the slowdown is?  Is it noticeable, or would it be in the noise
> > during all the other stuff that happens under memory pressure?
> 
> yup.

It is not really clear, how to quantify this properly. Let me think more
about it.

> And the "more testing is required" is a bit worrisome.  Is this
> code really ready for getting pounded upon in -next?

By now it survived 5+ hours of fuzzing in 16 VM in parallel. I'll continue
with other tests tomorrow.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
