Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D19CD82F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 16:26:23 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so44330822wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:26:23 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id sc5si111124wjb.17.2015.09.24.13.26.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 13:26:22 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so128726448wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:26:22 -0700 (PDT)
Date: Thu, 24 Sep 2015 23:26:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 04/16] page-flags: define PG_locked behavior on compound
 pages
Message-ID: <20150924202620.GA25005@node.dhcp.inet.fi>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1443106264-78075-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1509241106320.20701@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1509241106320.20701@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 24, 2015 at 11:08:29AM -0500, Christoph Lameter wrote:
> On Thu, 24 Sep 2015, Kirill A. Shutemov wrote:
> 
> > SLUB uses PG_locked as a bit spin locked.  IIUC, tail pages should never
> > appear there.  VM_BUG_ON() is added to make sure that this assumption is
> > correct.
> 
> Correct. However, VM_BUG_ON is superfluous. If there is a tail page there
> then the information in the page will be not as expected (free list
> parameter f.e.) and things will fall apart rapidly with segfaults.

Right. But would it provide any clues on what is going on?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
