Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DEA0C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FC8220679
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YVFZcHHR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FC8220679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 517846B0003; Sun, 23 Jun 2019 05:45:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9458E0002; Sun, 23 Jun 2019 05:45:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 390E68E0001; Sun, 23 Jun 2019 05:45:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3AD46B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 05:45:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 140so7374546pfa.23
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 02:45:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=SGbjyf75c99S79YkNwkfWRcRA4lvd4Chuhz40PQahwQ=;
        b=r6z/ieFyQCF4LUbI4VKYiYxE8P3apUlxT7/IOQi9KUBDjqzR4pMfW2elxRE0bjYnsN
         3A9Z/GVWsudp9b3zx3d99G7DAtSPcXjHq115SKJ7JChbW2KKnzoI6M+xLqLG5XO3vNxL
         trQ/I64vDeCS87jzWhXexCyAn5WRejf5+smLTwNHjTEP4kfSkT5bKjggq8NHSjRiw8ia
         sNgI9TWZ2+a5l+OTkUBhDIlCjGFMIalLNHvcMaGws9Xt9VjZtPJGumnX6jbYnsYHHgIB
         Sho32KUBNW88mnwDlH71VIObTn142sKOB1cKJf9KbKcM/gDrdl4G+dJkjTRJEFQUw6bs
         S2RA==
X-Gm-Message-State: APjAAAXiyaC7OT9sLa/ypNRg+ARVOQhHYe8I81w0nRCK3Y7QRQ0Tz7wq
	2n2CcZDg6ZT36fWv5KNKRyEbYP0rtAete3iiLQl/6mqCpX1o02qcu/nSVcXQWvYlnIZHvsk7XCG
	D2mmFiLBhSPaF2xnwDmdUDZgkGg7nGCxhIT1cdK8fKSVKxfoFMDfmuaQJg/3yMM+Y+g==
X-Received: by 2002:a63:4185:: with SMTP id o127mr26218023pga.82.1561283131368;
        Sun, 23 Jun 2019 02:45:31 -0700 (PDT)
X-Received: by 2002:a63:4185:: with SMTP id o127mr26217965pga.82.1561283130396;
        Sun, 23 Jun 2019 02:45:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561283130; cv=none;
        d=google.com; s=arc-20160816;
        b=uMOyzJDNwoSj5Eu3AKyKHJCtRg9pTvukGMaqQx3xbDSHaoSTp7OZIzkaUgqGxFIhpV
         vG/ucBD3Q2xAfzVUlEksU6yrnSBDcSVaZryk/Pi0WMsAHsXOkhqS4fGSaORRQUwffb6s
         H3nXVloE32BR5J9wDtUi1A/F/vU7OenpiVnXVQKbBc6DSeer1cupBYtZi8DtYhEQ4xB/
         O247iKJk4xUeh8885EYGeGjCzb6Ie8EKfiecczYOQ82DqRc2FODgctn7Y04B9ipEupOv
         sRtO8Yn1w6jYpclt+lq0iBQ/hGnruW3diaPFPLVSo+aMRbzaGR60fR02mL/nR5U6CCcp
         A8Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=SGbjyf75c99S79YkNwkfWRcRA4lvd4Chuhz40PQahwQ=;
        b=CF5pPqf5ZKhXv9nrL7/UjMbDG6GLlFaQan+8BFTtBNpjmWJTAC1rQlI4its3dgTcSd
         NhDX8I5SopYF7Uj/8eaqPYN5H8fXZ9Bgmp61k0pMroUdA9bnv/7TlZ1eScBU6UJuH/yY
         duCTMQxHVNY5wgHm7YJVih0mLy8alYjMjKIoPcYwf7B/2dk0DLF8wQffoZPjQhPPltBf
         +OIQVTWCsrzQIfcHh3yEweoRfMOka0wXa21qfD2Ajp2N+Ae4NemUq0qQUU6nWiJL2BBW
         qPMCUxsaVNQffhqO7EcNY+rzaB8L89zCHP4hwrOQO5w7W0D/Thmk4zBsPhKugsWjUmyI
         mWSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YVFZcHHR;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor9332700pln.13.2019.06.23.02.45.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 02:45:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YVFZcHHR;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=SGbjyf75c99S79YkNwkfWRcRA4lvd4Chuhz40PQahwQ=;
        b=YVFZcHHRNu+26snpxjow4PoPX3ej9w1hIhawqEAsLMcTCFID9VPgiJtIlfYY9I8ekU
         JHhCB/zPJAvezYn3+jBFu0jrKfoqfzKhqna855JLQGx61EWHs2G5OMlEx/F/HaXmqXxN
         uMqOC5FXfnnNAOI0hJ4vmhyOxsws4Dg0ROZovq00OX8kRtNeLxpcvzwvX24PKb5kFiI3
         NPSR927rYsfiApkiSg+JNTDLoCtfPdmnH3wB8TsvcQIU6Osdax+YeVE6+Hu7gbi9cIg7
         p3/Hd6FeQKKDDPFhvpfDMmiJQWFcL7m8XNy2VKJvSUMmUIRM1LpX9Ih3FSs/aqAQYOwf
         3y4w==
X-Google-Smtp-Source: APXvYqzi0wlf2RThtnnqN1XRmfWGl8V2A0Rdx29HeMZt12F8AiiBvwFVo8ATHxQq1XcX9A2BGcBKqQ==
X-Received: by 2002:a17:902:be10:: with SMTP id r16mr78309008pls.294.1561283129539;
        Sun, 23 Jun 2019 02:45:29 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([1.129.156.141])
        by smtp.gmail.com with ESMTPSA id d26sm6181062pfn.29.2019.06.23.02.45.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 02:45:28 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH 0/3] fix vmalloc_to_page for huge vmap mappings
Date: Sun, 23 Jun 2019 19:44:43 +1000
Message-Id: <20190623094446.28722-1-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a change broken out from the huge vmap vmalloc series as
requested. There is a little bit of dependency juggling across
trees, but patches are pretty trivial. Ideally if Andrew accepts
this patch and queues it up for next, then the arch patches would
be merged through those trees then patch 3 gets sent by Andrew.

I've tested this with other powerpc and vmalloc patches, with code
that explicitly tests vmalloc_to_page on vmalloced memory and
results look fine.

Thanks,
Nick

Nicholas Piggin (3):
  arm64: mm: Add p?d_large() definitions
  powerpc/64s: Add p?d_large definitions
  mm/vmalloc: fix vmalloc_to_page for huge vmap mappings

 arch/arm64/include/asm/pgtable.h             |  2 ++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 24 ++++++++-----
 include/asm-generic/4level-fixup.h           |  1 +
 include/asm-generic/5level-fixup.h           |  1 +
 mm/vmalloc.c                                 | 37 +++++++++++++-------
 5 files changed, 43 insertions(+), 22 deletions(-)

-- 
2.20.1

