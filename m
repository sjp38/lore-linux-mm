Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A93EC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:14:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 191D020665
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:14:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 191D020665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 952148E0001; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 834E46B000C; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60E8B6B0005; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8F66B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so17430477eda.9
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=gFaB4qI89d5CVVD3UTO1uMfi3o5ZKfpFbRPaT+kpMG0=;
        b=fPA6Y6DGqX+ayc2kRy0hgbRomtiCwZyFh1I9uBWeB7vTUO427ulGIbA7VJIHNo6aIz
         RQqQ5SEVyBPsYpf69A9/1s9g8PCQG4ATbSVJytsoz5bZSpqbMPMd/Whb3XliBcZ4fZJ0
         5vo80To4Nd5Gpeynj8oL6V8lFjWmqMbTiTyZA23sr34ljQH3WER5jVivj0IGqLQvITy7
         e5+VjhlkImOGmL8ZXNz1SGlauVNxYMuA5no6XdecnVS2rztzy0KYFIYGrjECqG2SHrpA
         yvAAB36cMdAwBmBAimPea8/foTAIDR9mqhJH7wAis7dqewbR1BEvhCn3tyLqaDgXBtrh
         R6Dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAXzyFVjT60wSi/Tfe2qE4o0P1NMgXnKB7GAPYN6fLB+vS6VLXkO
	vA98h/0e4iZfcxBBmupJE7K/MjVbeeaudxld/veKupjod90//oJ8k7ar4jKzyEWEbcFts/nZN7X
	pshZzXNstUgMrrgv1paC7ActUMKxSDCLsTNt0cKSxhCz6C/3QwUPbtn6tbmpyECO3UQ==
X-Received: by 2002:a17:906:69c4:: with SMTP id g4mr30072281ejs.9.1563347693708;
        Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXAW1YUb8xacKIUgQADingUx04h8JIQgWUv4plR9jamwVZ2FUIlwW275Som46r2iT8jotX
X-Received: by 2002:a17:906:69c4:: with SMTP id g4mr30072216ejs.9.1563347692575;
        Wed, 17 Jul 2019 00:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563347692; cv=none;
        d=google.com; s=arc-20160816;
        b=Jm3mYEs2xpFa2BJvZT3aOVGE9B8n9jPCKdYax+FB0WVZ0x41EJ6jJVbkxHlrw2ZAEy
         GYB0gLJssWo5/6R/el2wasRue1X0IwlwwusPSIvOfQDCW2DYs0rkn9J6Nv0G9+SOUCDB
         w2W/QLiIYVY2gGwQIyduvnGJGLvjRPGnpbeLHPImMaj9dkhfg9UVS5958gT5Q/oMUy6I
         4lRMuftgvlNp5AuExvOwEuGPgresX/g3Y9ZdsspaC8kS8aRCT+bmIctW2fRnJdqczm4a
         t2KZT9xwVafUReAi2TGOT3cHIxyYb512g7eeNrjsu+PXBwgVN6caPc3mrokpIkCUFvZ7
         bm9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=gFaB4qI89d5CVVD3UTO1uMfi3o5ZKfpFbRPaT+kpMG0=;
        b=KPhuiaSZVVwXcTS4AAA5wXXG4OOCIaMC8Liu4eZVSlBapw8vcXKOlGZ8TEIAkrH3KS
         2J8i3VGPoOudCXyR/79hvnarwwQbXO2kQN5omZAO9jva1gEqFk91KnagIPpPudRK1e13
         e66MCOb1ZHK02MZPpscG66w4iQKm7AkoQh1yT9zDs3OrY5uWlySEvqPo+v8av7yzCtyi
         Q13tWaDy+O6O3Wvxb16WKyb9TXDRLhEJqdgIg/4egyiYdAxI1JSwLo+aDhmqz+TQYSEv
         +v8dzWvfrPnFe35EXV1eJ+8OJu+5L64n/c4TFUg4iPzSlB9ucg/EG7gc14EpqqKQnisH
         lAWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id x58si14146778eda.238.2019.07.17.00.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 00:14:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) client-ip=2a01:238:4383:600:38bc:a715:4b6d:a889;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id C5C11284; Wed, 17 Jul 2019 09:14:51 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3 v2] Sync unmappings in vmalloc/ioremap areas
Date: Wed, 17 Jul 2019 09:14:36 +0200
Message-Id: <20190717071439.14261-1-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here is a small patch-set to sync unmappings in the
vmalloc/ioremap areas between page-tables in the system.

This is only needed x86-32 with !SHARED_KERNEL_PMD, which is
the case on a PAE kernel with PTI enabled.

On affected systems the missing sync causes old mappings to
persist in some page-tables, causing data corruption and
other undefined behavior.

Please review.

Thanks,

	Joerg

Changes since v1:
	- Added correct Fixes-tags to all patches

Joerg Roedel (3):
  x86/mm: Check for pfn instead of page in vmalloc_sync_one()
  x86/mm: Sync also unmappings in vmalloc_sync_one()
  mm/vmalloc: Sync unmappings in vunmap_page_range()

 arch/x86/mm/fault.c | 9 +++++----
 mm/vmalloc.c        | 2 ++
 2 files changed, 7 insertions(+), 4 deletions(-)

-- 
2.17.1

