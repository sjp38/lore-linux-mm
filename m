Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C71936B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:37:53 -0400 (EDT)
Received: by wixm2 with SMTP id m2so38470131wix.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:37:53 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id eb1si4755635wib.34.2015.03.27.09.37.51
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 09:37:52 -0700 (PDT)
Date: Fri, 27 Mar 2015 18:37:26 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 04/16] page-flags: define PG_locked behavior on compound
 pages
Message-ID: <20150327163726.GA24590@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <55157384.6020209@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55157384.6020209@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Krawczuk <m.krawczuk@samsung.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

On Fri, Mar 27, 2015 at 04:13:08PM +0100, Mateusz Krawczuk wrote:
> Hi!
> 
> This patch breaks build of linux next since 2015-03-25 on arm using
> exynos_defconfig with arm-linux-gnueabi-linaro_4.7.4-2014.04,
> arm-linux-gnueabi-linaro_4.8.3-2014.04 and
> arm-linux-gnueabi-4.7.3-12ubuntu1(from ubuntu 14.04 lts). Compiler shows
> this error message:
> mm/migrate.c: In function a??migrate_pagesa??:
> mm/migrate.c:1148:1: internal compiler error: in push_minipool_fix, at
> config/arm/arm.c:13500
> Please submit a full bug report,
> with preprocessed source if appropriate.
> See <file:///usr/share/doc/gcc-4.7/README.Bugs> for instructions.
> 
> It builds fine with arm-linux-gnueabi-linaro_4.9.1-2014.07.

Obviously, you need to report bug against your compiler. It's not a kernel
bug.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
