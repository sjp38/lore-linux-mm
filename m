Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F30FFC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB461222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB461222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A1958E0002; Wed, 13 Feb 2019 03:06:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329B58E0001; Wed, 13 Feb 2019 03:06:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CE018E0002; Wed, 13 Feb 2019 03:06:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B78FB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:06:40 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so650209edz.15
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:06:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=5Yok6c29GSa+wARKscP5GIlvIiMzMDwnnYzq4du5EOU=;
        b=grO+1gMxg3zmFr3SRjYpmUC0pEzJZFFuqO07xsox8yEhcHQtR+RbJlTF8FMMEahCE9
         53aRjB2r23VUZJw2/O8rqcJ078OwtBSLurj65ljAXJW6/I/zHh+RmWw/umZyVLgcOtm1
         y1lznNB2i4TsiwIl8md/QTjNb9FXbgBxB/QX/hTEqAHyO6RjxZrWaFYU3VKhovm1vkzb
         U2Py1Q0KsEfN3I2NXs+5+njYS4vU3a0xNJsKCH/MerVYDkvzJ7jEDJbai2JJkxcLPW8S
         IGcGrOUcsYeKxmf5bZiha2KFiWLps8KNU6cy1W/6avKcL/h8TmE9aXkZZKUTad+lsHSM
         I5WQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZWdOW5z0ESh/IHlWJGkA9bXui0gSQIpgx7TipzQ+1a+BPLgUtL
	LVTARKCod24xTKy2ItKGer89PXi+07gfzKAnMIR+X8imK/TqYnBYIBlfMEBMUa95TisVS0/91FX
	bW+1JfF9NfRRDpz96CAnw7nli4JGln9SC8zV+n/mnAuz38RwO2WKSwufPf9y3r8IsJQ==
X-Received: by 2002:a50:8a45:: with SMTP id i63mr6524984edi.262.1550045200147;
        Wed, 13 Feb 2019 00:06:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6YUjKDOUg2uwgyz2LHn9LJkx3jysTd7i7NpIuZUEQjo0rD/oOtmVu1Iu6tSvmCrWKKet4
X-Received: by 2002:a50:8a45:: with SMTP id i63mr6524927edi.262.1550045199000;
        Wed, 13 Feb 2019 00:06:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045198; cv=none;
        d=google.com; s=arc-20160816;
        b=TP/KB63RzzbNVW9UuEWQ2mJXwEeDSR5QmxDkKIqXFmfQq9Q2LXwOgYD4qUGpciD6/f
         PDIYlkNT73U9lglFCvrKiKdzyQKbNnyU4riS38FPiXg/Yzq7zC0fuNZ2lYajLuAZRwwg
         wVZULCUbYi+lFmpsAuu82b7I1C6BF9S5V8/CaFq2T+kvWxB+cyIMILnKreitVNI7EJEV
         ptASj7nX1aKC6ho95CnVoHgb3HIdpVSry/r63GF8sDixxjYvRGMNLi9kMdgtZ7sfXfTU
         bUYSTiT6nYu+WsuHI4I9XTzpAmAb2PG/SsRh7qp9QZ3hHRaQ2CPvf+xt14EEHhIHAG1l
         M4wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=5Yok6c29GSa+wARKscP5GIlvIiMzMDwnnYzq4du5EOU=;
        b=cmrCJlzsz4VA5AybB00YHmvdUuypJa0sHrK25ZiURYNGS7VXiVbHi4xSfy2DLSdX2F
         3fF0dqtc/gz3a/Kd3dEtMiNJNDMYFggn46zxDQmprvTkkbZKloW1Xsz+ECTVRr5e8QPk
         90qe5hSu9uZNdorHxLon41PxpL5GHO6YC4f0fMPSJ3QxDm6KOq8HqfGX6XxzGrIL5MT0
         7J7k7PzM9T/IloJO0Z1UsS+dODK2S75GZIxrIBNPRNkQ2lLvOkMfcmAlmQbYNQg1wf+9
         67iu3bJAlqYWzk4lVk46Qj9c+bT7ycGrCrYUvNiFml0te7lulhyUL9FABbCgCMRiWnMB
         SxYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b46si540649edd.183.2019.02.13.00.06.38
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 00:06:38 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9A90280D;
	Wed, 13 Feb 2019 00:06:37 -0800 (PST)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.147])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 316C03F575;
	Wed, 13 Feb 2019 00:06:33 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	kirill@shutemov.name,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	dave.hansen@intel.com
Subject: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Date: Wed, 13 Feb 2019 13:36:27 +0530
Message-Id: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Setting an exec permission on a page normally triggers I-cache invalidation
which might be expensive. I-cache invalidation is not mandatory on a given
page if there is no immediate exec access on it. Non-fault modification of
user page table from generic memory paths like migration can be improved if
setting of the exec permission on the page can be deferred till actual use.
There was a performance report [1] which highlighted the problem.

This introduces [pte|pmd]_mklazyexec() which clears the exec permission on
a page during migration. This exec permission deferral must be enabled back
with maybe_[pmd]_mkexec() during exec page fault (FAULT_FLAG_INSTRUCTION)
if the corresponding VMA contains exec flag (VM_EXEC).

This framework is encapsulated under CONFIG_ARCH_SUPPORTS_LAZY_EXEC so that
non-subscribing architectures don't take any performance hit. For now only
generic memory migration path will be using this framework but later it can
be extended to other generic memory paths as well.

This enables CONFIG_ARCH_SUPPORTS_LAZY_EXEC on arm64 and defines required
helper functions in this regard while changing ptep_set_access_flags() to
allow non-exec to exec transition.

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html

Anshuman Khandual (4):
  mm: Introduce lazy exec permission setting on a page
  arm64/mm: Identify user level instruction faults
  arm64/mm: Allow non-exec to exec transition in ptep_set_access_flags()
  arm64/mm: Enable ARCH_SUPPORTS_LAZY_EXEC

 arch/arm64/Kconfig               |  1 +
 arch/arm64/include/asm/pgtable.h | 17 +++++++++++++++++
 arch/arm64/mm/fault.c            | 22 ++++++++++++++--------
 include/asm-generic/pgtable.h    | 12 ++++++++++++
 include/linux/mm.h               | 26 ++++++++++++++++++++++++++
 mm/Kconfig                       |  9 +++++++++
 mm/huge_memory.c                 |  5 +++++
 mm/hugetlb.c                     |  2 ++
 mm/memory.c                      |  4 ++++
 mm/migrate.c                     |  2 ++
 10 files changed, 92 insertions(+), 8 deletions(-)

-- 
2.7.4

