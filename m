Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 217A26B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:36:14 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id u190so113286310pfb.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 02:36:14 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id o63si11398204pfi.141.2016.03.17.02.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 02:36:13 -0700 (PDT)
Subject: ARC !THP broken in linux-next (was Re: [PATCH V2] mm/thp/migration:
 switch from flush_tlb_range to flush_pmd_tlb_range)
References: <1455118510-15031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56EA7A78.6020308@synopsys.com>
Date: Thu, 17 Mar 2016 15:05:52 +0530
MIME-Version: 1.0
In-Reply-To: <1455118510-15031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-next <linux-next@vger.kernel.org>

Hi Aneesh,

On Wednesday 10 February 2016 09:05 PM, Aneesh Kumar K.V wrote:
> We remove one instace of flush_tlb_range here. That was added by
> f714f4f20e59ea6eea264a86b9a51fd51b88fc54 ("mm: numa: call MMU notifiers
> on THP migration"). But the pmdp_huge_clear_flush_notify should have
> done the require flush for us. Hence remove the extra flush.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

linux-next fails for ARC with this - although this is not your fault.
Back then, per your request I did verify that ARC builds fine with this for
CONFIG_TRANSPARENT_HUGEPAGE worked. However I failed to check the !THP case which
is broken.

@Andrew could you please add the patch below to mm tree !

Thx,
Vineet

------------>
