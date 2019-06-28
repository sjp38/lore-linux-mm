Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA77C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 04:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7100E2070D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 04:45:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7100E2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04796B0003; Fri, 28 Jun 2019 00:45:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8E638E0003; Fri, 28 Jun 2019 00:45:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2FB88E0002; Fri, 28 Jun 2019 00:45:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7228B6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 00:45:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c27so7703484edn.8
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 21:45:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=FfgNeG37hv04EKofspx0hDFJPuh4IQFpaKJdQSMm0B0=;
        b=GW+h15473XXwIPNtXzZikeB4P+Dm9FcTmI+BPSeDluM5KA6R0Xb+B5AqH8SzciKeku
         xlK4pjKeQ5OvryloThFyxS63uR692/l/b1MCYGQWZMuOHC+KFjGYFEOCGOEef2rgMvH9
         Jo3aQqebvvGxFQnK43CUEZUEc8UwCFNdLbklmiQSYGcBVj5orSypexOe2FPcUZiTCz/h
         755iEB8bjIF5KRAY81TANbmRf9tnxl6wy+hnH7LeFJQ8zsBcva4uRHjUBgZ8Oc1Iz+AJ
         8nEAK+f+GZQWT7dYYgBPHngLFpf16qHp4SB6MJBFVavDaj/+WhgSp7uhhPOLphm08uJ4
         zlXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX27qzYMEqd09J7/O9X6lNm51rdYsKIcUqVklip05XF4q2qfYTB
	rFqr0LIqbpTnA+8CpARDFG1I+cKzdH4M2rlq5TAcWBTaevKGxKHuQzEEjA0FebYPXVkZgvuyYqi
	2zJrZPHrNPU9s0Y9vaNqJtM2za1ADR35gIPPJZH4tln11/WekDFH7Orc8403JiFxaBw==
X-Received: by 2002:a50:91ae:: with SMTP id g43mr8733515eda.279.1561697107949;
        Thu, 27 Jun 2019 21:45:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziHrbcWBWtNihTjt0Nv6Uz6l+mjQX3cxLl4KIWQORLH+ZuIQeMCWyBEjk69sXvsawXivaz
X-Received: by 2002:a50:91ae:: with SMTP id g43mr8733462eda.279.1561697107157;
        Thu, 27 Jun 2019 21:45:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561697107; cv=none;
        d=google.com; s=arc-20160816;
        b=j9i0yK3a72eaGjL2mbgs4YtuGwLPmXmzm+x8nQuSJp6o6PBLOT87wMUlKA0GW0eRZh
         99yK8jRRcnpzaPv2hYV39QE7EFXYqu+WTI+rI8O1zwWgWs0+psvNI98hE0uUY7LqniGb
         l3HEeV/QaqfaxPdZYF1XwClTOAhs1k4qhqXWvcnnchV4mdjOo2BqmQqTYgty2038kbgb
         /8aLc0+yr0/ys88heMHQ79p+w/3BQdfdvDM2p8MpGUeZo+KABdJ10Dq2shTyebReYZLW
         MXZQWJHUEmsa4etJT6k2ZsMWosVJhO5Cbmto2P13dz4144Pw35+b3r/ke64W/SZ4s+J6
         adxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=FfgNeG37hv04EKofspx0hDFJPuh4IQFpaKJdQSMm0B0=;
        b=fR6pTSCHzrYEN6e6guSBI+WihKh1LMeVnL0qkGLsgyb5gCNaqiwIl7jO7LelZpqU0F
         S13Rg+mGY8CM7ttMeiAW6EwKAknwfz9S6SpPvRDpW9dGHSHJDlo6S615/fNOs2lPGbId
         zMvtgjvU4hADewS7dIMN+q4YROclIoxEmvBqpwO1+MEshVARRbFY8S5O+9MDAo1mhVcj
         C0R0CqcYqgfWnvp0HnXKOkHX3Gu9G00BXqDBUTR5KvURgELMARri77IBt5KdyVd08Ld6
         ygF2hhxJomxBbJaSo/tEq7uvyHD3UL0MpKJ4XgNdGzeJVsvS5Icvvnui4mVCUDQkQwLN
         e0Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l30si924542edd.139.2019.06.27.21.45.06
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 21:45:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E51F344;
	Thu, 27 Jun 2019 21:45:06 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 3F65A3F706;
	Thu, 27 Jun 2019 21:45:02 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-ia64@vger.kernel.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 0/2] arm64: Enable vmemmap from device memory
Date: Fri, 28 Jun 2019 10:14:41 +0530
Message-Id: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables vmemmap mapping allocation from device memory ranges on
arm64. Before that it enables vmemmap_populate_basepages() to accommodate
struct vmem_altmap based requests.

This series is based on linux next (next-20190613) along with v6 arm64
hot-remove series [1]. 

[1] https://lkml.org/lkml/2019/6/19/3

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org

Anshuman Khandual (2):
  mm/sparsemem: Add vmem_altmap support in vmemmap_populate_basepages()
  arm64/mm: Enable device memory allocation and free for vmemmap mapping

 arch/arm64/mm/mmu.c      | 57 +++++++++++++++++++++++++++++++-----------------
 arch/ia64/mm/discontig.c |  2 +-
 arch/x86/mm/init_64.c    |  4 ++--
 include/linux/mm.h       |  5 +++--
 mm/sparse-vmemmap.c      | 16 +++++++++-----
 5 files changed, 54 insertions(+), 30 deletions(-)

-- 
2.7.4

