Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 417626B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 04:46:48 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so40413362pad.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:46:48 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id ts3si40350474pab.81.2015.09.03.01.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 01:46:47 -0700 (PDT)
Subject: Re: [PATCH 00/11] THP support for ARC
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <55E808E2.2080102@synopsys.com>
Date: Thu, 3 Sep 2015 14:16:26 +0530
MIME-Version: 1.0
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com

Hi all,

On Thursday 27 August 2015 02:33 PM, Vineet Gupta wrote:
> Hi,
> 
> This series brings THP support to ARC. It also introduces an optional new
> thp hook for arches to possibly optimize the TLB flush in thp regime.
> 
> Rebased against linux-next of today so includes new hook for Minchan's
> madvise(MADV_FREE).
> 
> Please review !
> 
> Thx,
> -Vineet

I understand that this is busy time for people due to merge window. However is
this series in a a review'able state or do people think more changes are needed
before they can take a look.

I already did the pgtable_t switch to pte_t * as requested by Kirill (as a
separate precursor patch) and that does requires one patch in this series to be
updated. I will spin this in v2 but was wondering if we are on the right track here.

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
