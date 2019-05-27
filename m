Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5123CC46460
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 21:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 071AC2133F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 21:11:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 071AC2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 746596B027F; Mon, 27 May 2019 17:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F3DE6B0283; Mon, 27 May 2019 17:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCC96B0281; Mon, 27 May 2019 17:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 214BC6B027A
	for <linux-mm@kvack.org>; Mon, 27 May 2019 17:11:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 93so11859360plf.14
        for <linux-mm@kvack.org>; Mon, 27 May 2019 14:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=x2Hnj5lXG050I/40c6QcapIrfrtP44/pvgj5PrK4OWY=;
        b=NeS214i35HfvAirosM9LsFSMulT27oBRevAMcIbWBF8S3izDMDbqH/Z57+abCoSko8
         5rSBvAC+VyNSxVX/Sw2GxIq0vACCXMQ+Z4roeteCfcdico1vSc+tvM+2S921GR1CdFOR
         v3pRzjD3gvVCsW+U2qN2lzHG5YkHCzyGcrmRmEl830XOIVxckY8BKQww17bRyeeqXFsg
         d3OrPeYYQtBDK8IBhaf/DnbYm8k9TgcgX4mwTPGjkNSkjmR8hE5djUWh7jI6pG31+xvG
         hDLuY8IIGxGOEUOAW3GS7AzOW2x1X5cKypPfJxfV2UtkqkNQRggqw0BlRgr6t2ivWEii
         S3iA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVtL0qSqFK0f+Aq4puBR18Ji5XZ64ZxTRkW6CcNplfNrnSQjK+A
	Mw203L3dnZW8JJmFxNGgoj3LjM7ZjQCVtu0zVThh/KITqMHgiu9YGM3V5MmDWquD18u3ghBBkyC
	MtG+EM0OwyJ3d7Yw0rIbV5EuMxNhvLLV3bOud/IFM9RbKa5d7Ty3CAIMrCab3WdAKBA==
X-Received: by 2002:a17:90a:af8e:: with SMTP id w14mr925661pjq.89.1558991485806;
        Mon, 27 May 2019 14:11:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVmOnl+u7EWaxyGPPoDEp3MZ5hrCUT3LZNNWYhAQOPE2l/CGaP5rFsnK69SWd2+coBJytj
X-Received: by 2002:a17:90a:af8e:: with SMTP id w14mr925587pjq.89.1558991484657;
        Mon, 27 May 2019 14:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558991484; cv=none;
        d=google.com; s=arc-20160816;
        b=E/wa2LH7psW6LRYVam8NHlQR/YBlZr5F7YQXsOxRmYau9OADLdnD4D8IUSnGAUZcUN
         hzU87K8qNFu1B6rfnA60BItvjgQCLlUolUzewi+1Vw8AaW38aj9nHULwS6YsSfFpGhZ8
         gcPyBo5y2TwNckVbGzzE+ucaqu0BNAVbPo+0fbAkV2F0t8hYpp0XhnCEzeyIAe64viR4
         PYK2Z798Rv+LJvKj6cFIZ9e2kl8OHj6B8rTC+9scM7x7bgUzg4bGF5fBnqdmV9EFl99B
         UUNnzbNACU6TgIqAgNizWU+8HXU9cBTuS7Sem44rjbHITmfJjIjoDDXyexANPCITwCn6
         n4tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=x2Hnj5lXG050I/40c6QcapIrfrtP44/pvgj5PrK4OWY=;
        b=IDJrqsVFbue3icjXaq2fKX7ByUlgRsS9BpmC313qq10I0/AiW6/SJ8tFLfMZ3tbz0H
         z9JEktve9amHSUSWz6Lhqtw1aoKSCq4RmlHFY0MHKRVWSOEpN2CpAQo6pVKlPMK/+uLA
         2wMwBE2mdf7VxJPBJIhK8nWrxNPqG7okH76fJx2/Og2q3eEXlqYP5wUxaGGqdnX/VHVe
         1UJSJ5lAYLyIlQx3HHIy+6FyxyX8kaj2zKUDqv58FVobL2hEVMyTTebh0JfXjyE5lSU4
         y++9sZOgu0fC1vl8BDyiA8/BKvwBMqgkCV5iYN+3cy7MIcVAeKxELdCpMcqXTyRtpkzQ
         6oOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q33si502821pjb.30.2019.05.27.14.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 14:11:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 May 2019 14:11:24 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.251.0.167])
  by orsmga008.jf.intel.com with ESMTP; 27 May 2019 14:11:23 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v5 0/2] Fix issues with vmalloc flush flag
Date: Mon, 27 May 2019 14:10:56 -0700
Message-Id: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These two patches address issues with the recently added
VM_FLUSH_RESET_PERMS vmalloc flag.

Patch 1 addresses an issue that could cause a crash after other
architectures besides x86 rely on this path.

Patch 2 addresses an issue where in a rare case strange arguments
could be provided to flush_tlb_kernel_range(). 

v4->v5:
 - Update commit messages with info that the first issue will actually
   not cause problems today
 - Avoid re-use of variable (PeterZ)

v3->v4:
 - Drop patch that switched vm_unmap_alias() calls to regular flush (Andy)
 - Add patch to address correctness previously fixed in dropped patch

v2->v3:
 - Split into two patches (Andy)

v1->v2:
 - Update commit message with more detail
 - Fix flush end range on !CONFIG_ARCH_HAS_SET_DIRECT_MAP case


Rick Edgecombe (2):
  vmalloc: Fix calculation of direct map addr range
  vmalloc: Avoid rare case of flushing tlb with weird arguments

 mm/vmalloc.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

-- 
2.20.1

