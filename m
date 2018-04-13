Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 281006B000A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:34:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e9so4635226pfn.16
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:34:10 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d5si3890860pgc.236.2018.04.13.04.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 04:34:09 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH 0/2] vunmap and debug objects
Date: Fri, 13 Apr 2018 17:03:52 +0530
Message-Id: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>

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

Chintan Pandya (2):
  mm: vmalloc: Avoid racy handling of debugobjects in vunmap
  mm: vmalloc: Pass proper vm_start into debugobjects

 mm/vmalloc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation
Center, Inc., is a member of Code Aurora Forum, a Linux Foundation
Collaborative Project
