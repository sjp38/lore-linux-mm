Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 951FF82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:43:18 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id b35so27925818qge.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:43:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a7si7549224qhd.24.2016.02.03.14.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:43:18 -0800 (PST)
Date: Wed, 3 Feb 2016 14:43:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
Message-Id: <20160203144316.f01573516f186071bb2cf1bf@linux-foundation.org>
In-Reply-To: <56B21FC9.9040009@intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1454512459-94334-5-git-send-email-kirill.shutemov@linux.intel.com>
	<56B21FC9.9040009@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Feb 2016 07:42:01 -0800 Dave Hansen <dave.hansen@intel.com> wrote:

> On 02/03/2016 07:14 AM, Kirill A. Shutemov wrote:
> > But the new variant is somewhat slower. Current helpers iterates over
> > VMAs the compound page is mapped to, and then over ptes within this VMA.
> > New helpers iterates over small page, then over VMA the small page
> > mapped to, and only then find relevant pte.
> 
> The code simplification here is really attractive.  Can you quantify
> what the slowdown is?  Is it noticeable, or would it be in the noise
> during all the other stuff that happens under memory pressure?

yup.  And the "more testing is required" is a bit worrisome.  Is this
code really ready for getting pounded upon in -next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
