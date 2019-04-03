Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18E11C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA975206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA975206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 703B76B0290; Wed,  3 Apr 2019 00:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B4916B0292; Wed,  3 Apr 2019 00:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A3656B0293; Wed,  3 Apr 2019 00:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09C616B0290
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p88so6799967edd.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=CXTPUJH63sQhSZ8X2JP4briWNtesBoJzD59pdvE9buM=;
        b=pbXmPuxU1kCTa2/9YEvTSfNFZ8PTYEYigIaOdAG++2DqJtcs9fBHFoeCil3XhtjoTC
         uOFCz5yoeApoHEoOZG7G6NKEY0dlRjwZGap836yqVJ99BabAq5WAsp9T0Gqmdh9KNXkg
         VaaJtm1VnRa9CFycnU81FW0uOpWWE0ZuXVKZS7Lv36KXcFV/MOswwe2v5jH1/BDXTTRG
         vVfn9e2ZkbDrKBigOcZplv+t/cxZslPF0MypNYFLgnXeQVLd62XcGrk35TnxeHLrfOWq
         hyJBYUfsg1YWbakJIgTsjAivYg4J4dWyw4KrM8i4KDs4FXX5lkKX1cXvJSDsnpqW8DU7
         wrQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWmP9rYqglomiLOCChMi7OsB2G6VVOlFNREiLAYLcp4w2jKWHVi
	hDBHshaESGa19kx3CQgGLlMddAbXF+HV94ZiTIFRogV00n9Un3ZCjSW39k1ibEbl94U34rBPqrb
	/mVGBpLH9EKUHq/sVxEYNZbK8U5sQ1pFHVBf1zHbH35yLHpKqA1AcbvudpB9zHi8wKw==
X-Received: by 2002:a17:906:c9c6:: with SMTP id hk6mr686442ejb.113.1554265850553;
        Tue, 02 Apr 2019 21:30:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLxqBGk0m832ebxF0phJIxShQ8X7bD2YiZtq8c9jUfUljLxBp0A+nthCTJi4jQ1PZo2B5Y
X-Received: by 2002:a17:906:c9c6:: with SMTP id hk6mr686399ejb.113.1554265849393;
        Tue, 02 Apr 2019 21:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265849; cv=none;
        d=google.com; s=arc-20160816;
        b=t8a4qeqL2ftuf65Cl3ilNZ/TYl+b5iNCXA7ONsm5rqra2mtuqOB4Mpxi8Poooceetp
         X8scg/MF5wRUFdEfTIOdOcGASnQMyQ35nqVb9Mt1ALtCpW0H3Q1uH+03XvHsu+cH+PKN
         CNtZkZkOclgHsTMIvVPf2dE/BSrAtCO/8ReqancAGi3d4NBIUOcSHZ4XOXlGXLGP6lZX
         DfSlUnscuoD2N0ub0qtTOv52jpDPMPeesHM3Ki9AvdOKahthdomNX0aoyxUrL1+pbfUz
         o5P7Hk7GLf9+hqXSEDnrGFAdFs0WpoRl4BLq2GAOCwTwv5ZzzrT7COnc934duS3j0feI
         yLsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=CXTPUJH63sQhSZ8X2JP4briWNtesBoJzD59pdvE9buM=;
        b=ufIJRRFei1U4WXVxZIVoX+S1f0DNl2b1rgJI5gTrBtB3roJbAvI7ni92zIpccnWmnq
         0dKPlS9zePhg5owyM26fYhjvOukhy6TFYLQuV7m2nljJZFXRk5i/5Piw5mvJ4CA9BZyY
         uwTbGgQ5rQ9sxIFvXX8XkVS3ZxCYzP3BV4i9EgEyoTZGar/JDgPjxtmHbcnD/PO3cvn0
         Hgdj0Ox/ZCTe4vKJC/sM4h6I5WBVEeWp9ksMEMKQqhXSHgXZRq34euYx29BG48mMZXIQ
         s1xvGhWRImIc23tMkaZx+sTT+3G9TSgVRDLpCMY6tVaci0dimtCMPxsv5ReqsZsb7Uao
         Ts5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f11si1534763edt.109.2019.04.02.21.30.49
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 82E851596;
	Tue,  2 Apr 2019 21:30:48 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 0EB103F721;
	Tue,  2 Apr 2019 21:30:42 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
Date: Wed,  3 Apr 2019 10:00:06 +0530
Message-Id: <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Arch implementation for functions which create or destroy vmemmap mapping
(vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
device memory range through driver provided vmem_altmap structure which
fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just
enable ZONE_DEVICE by subscribing to ARCH_HAS_ZONE_DEVICE. But this is only
applicable for ARM64_4K_PAGES (ARM64_SWAPPER_USES_SECTION_MAPS) only which
creates vmemmap section mappings and utilize vmem_altmap structure.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index db3e625..b5d8cf5 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -31,6 +31,7 @@ config ARM64
 	select ARCH_HAS_SYSCALL_WRAPPER
 	select ARCH_HAS_TEARDOWN_DMA_OPS if IOMMU_SUPPORT
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
+	select ARCH_HAS_ZONE_DEVICE if ARM64_4K_PAGES
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_INLINE_READ_LOCK if !PREEMPT
 	select ARCH_INLINE_READ_LOCK_BH if !PREEMPT
-- 
2.7.4

