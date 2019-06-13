Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 469EDC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:44:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19CA620B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:44:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19CA620B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 940C16B0006; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F1BE6B0007; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B8946B000A; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4550C6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l4so13607970pff.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=BPSMRMKSv2OHOrnU4JqHbQlh++1TVkwpzXUIku+F3kE=;
        b=Wq+yH5tJJE3aSWU51xWhoE3pCg/ZagnfrBw+EihqLxxcY/11vZZFRjh++goHCzimNz
         iBOqoagNsezKsDWLhSg7xyHcuU8I++dvDKGNVX/cd7oRlzk6J4myOXhfV9rYEIHuCRSX
         m4XF1mIJxc88aq+0WDPWveRq0XEQVoXWRq8A3wRILi2NyFvWhLhBn2pDgUZnqtmBuwhm
         mDY6Fp5vVZ3skwF/ui+biGIk7j7nETgrE00HN8s6zul62VzQm0RS58N3A6UHxBkbQGDv
         8q+tfiXhdJMLUUl30yZtfBKoEcSiYGCDhWv7I3cPjkVvPOBVJVpIxcRrHGWrOS3IZASE
         WfvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUq9p8/YxKeejOYhUJUh2el2mGSwz8k9dyPHNp7oeEshsD916QM
	FR25vIkaFC6q6YxC2psDtWiVo43isfBzvFxSq4SIbpXmMFln6myP8xqqHDjpoOJyfL+ueFO5Ytt
	hOZree1cDNy5kP5DFPopxTPpV0+zqWzwgX4y9tu2OR8XWZm5y5cIKoYhBLhWhO+bbtQ==
X-Received: by 2002:a62:3103:: with SMTP id x3mr9649750pfx.107.1560401074915;
        Wed, 12 Jun 2019 21:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL2gl4rizRgoHKZvuejH9HjfJBhqzg8HpiHHxvme0Ga8DdRo1IUYpzeYXwvu+lvuLUTyum
X-Received: by 2002:a62:3103:: with SMTP id x3mr9649649pfx.107.1560401074025;
        Wed, 12 Jun 2019 21:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560401074; cv=none;
        d=google.com; s=arc-20160816;
        b=BgUZbhc+VWfGQ/RDnNbu7T7QOprJUtn0JHRO+wGZSTYImKL69M05dJ0jkT67Hidjiy
         t/tAorHN65YPsCn1uT/JRWsmPek+Ud9Qe6CP3sDhzhB1tVz2u2kGXV2uqtuyKNzVv71r
         EzLDgZKJI3GNJoz78hToP05Wf3BsJRu6miQ5mKufz+Sy/m1GS4j3zIlFEZVk8z5QBhpE
         KtcQhrCQEGT28GCFwpzX17K4O3Rzm30chZwuQr5bFTTxYJFxXeZf+VMzxp9TrtOt5lYx
         vpGbbfnfOxvNQmWAIRA4ldEwPf9BFSu55clFrIqGott1P6BwJpLwCUHNPIrkfGwpMlcU
         ztUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=BPSMRMKSv2OHOrnU4JqHbQlh++1TVkwpzXUIku+F3kE=;
        b=shbq2EnjgVag29Q5PAGu/jQNNaKE6m5NLKVlwklR5GGU1b0EdBKokjHanw0GrBAnM9
         KD6IThxWR1xeT1lA5BLCwIVtvWlruWSafNDpJypVu4yaCLQr00oMAT3YxF3/0Dx3RCsn
         AXDxNT0VKWaQ0b4gx4f1X21763IUPT6yHVouzlGY+24qWjr+5qJeNFoFUbV06x0ZnSB3
         uHGlY7DHgSHbwcdilj3csyr8QG4a76v8XI72lY0vaVujDSF8AZdtQtG7XtdeNl3+FNYx
         u3nFbNbrkMpw9j8QEoD3JQaRfvSkyiuq5Kmx64ddCIyf2OKiKIuPNensY+Ufw9lUM/H+
         Pzgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id q17si169066pgv.62.2019.06.12.21.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 21:44:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TU25N7U_1560401051;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU25N7U_1560401051)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 12:44:19 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: hughd@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 0/2] Fix false negative of shmem vma's THP eligibility
Date: Thu, 13 Jun 2019 12:43:59 +0800
Message-Id: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
vma") introduced THPeligible bit for processes' smaps. But, when checking
the eligibility for shmem vma, __transparent_hugepage_enabled() is
called to override the result from shmem_huge_enabled().  It may result
in the anonymous vma's THP flag override shmem's.  For example, running a
simple test which create THP for shmem, but with anonymous THP disabled,
when reading the process's smaps, it may show:

7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
Size:               4096 kB
...
[snip]
...
ShmemPmdMapped:     4096 kB
...
[snip]
...
THPeligible:    0

And, /proc/meminfo does show THP allocated and PMD mapped too:

ShmemHugePages:     4096 kB
ShmemPmdMapped:     4096 kB

This doesn't make too much sense.  The shmem objects should be treated
separately from anonymous THP.  Calling shmem_huge_enabled() with checking
MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
dax vma check since we already checked if the vma is shmem already.

The transhuge_vma_suitable() is needed to check vma, but it was only
available for shmem THP.  The patch 1/2 makes it available for all kind of
THPs and does some code duplication cleanup, so it is made a separate patch.


Changelog:
v3: * Check if vma is suitable for allocating THP per Hugh Dickins
    * Fixed smaps output alignment and documentation per Hugh Dickins
v2: * Check VM_NOHUGEPAGE per Michal Hocko


Yang Shi (2):
      mm: thp: make transhuge_vma_suitable available for anonymous THP
      mm: thp: fix false negative of shmem vma's THP eligibility

 Documentation/filesystems/proc.txt |  4 ++--
 fs/proc/task_mmu.c                 |  3 ++-
 mm/huge_memory.c                   | 11 ++++++++---
 mm/internal.h                      | 25 +++++++++++++++++++++++++
 mm/memory.c                        | 13 -------------
 mm/shmem.c                         |  3 +++
 6 files changed, 40 insertions(+), 19 deletions(-)

