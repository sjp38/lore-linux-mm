Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E88136B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:44:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g61-v6so12126500plb.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 03:44:06 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id g11si6684067pgq.329.2018.04.17.03.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 03:44:05 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v2 0/2] vunmap and debug objects
Date: Tue, 17 Apr 2018 16:13:46 +0530
Message-Id: <1523961828-9485-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, mhocko@kernel.org, Chintan Pandya <cpandya@codeaurora.org>

I'm not entirely sure, how debug objects are really
useful in vmalloc framework.

I'm assuming they are useful in some ways. So, there
are 2 issues in that. First patch is avoiding possible
race scenario and second patch passes _proper_ args
in debug object APIs. Both these patches can help
debug objects to be in consistent state.

We've observed some list corruptions in debug objects.
However, no claims that these patches will be fixing
them.

If one has an opinion that debug object has no use in
vmalloc framework, I would raise a patch to remove
them from the vunmap leg.

Below 2 patches are rebased over tip + my other patch in
review "[PATCH v2] mm: vmalloc: Clean up vunmap to avoid
pgtable ops twice"

Chintan Pandya (2):
  mm: vmalloc: Avoid racy handling of debugobjects in vunmap
  mm: vmalloc: Pass proper vm_start into debugobjects

>From V1->V2:
 - Incorporated Anshuman's comment about missing corrections
   in vm_unmap_ram()

 mm/vmalloc.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation
Center, Inc., is a member of Code Aurora Forum, a Linux Foundation
Collaborative Project
