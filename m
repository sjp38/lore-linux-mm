Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0DF5C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:40:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A21922145D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:40:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jt7i+Ah0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A21922145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17BFF8E000D; Mon,  1 Jul 2019 02:40:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12DC48E0002; Mon,  1 Jul 2019 02:40:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F375C8E000D; Mon,  1 Jul 2019 02:40:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id BD5D08E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:40:51 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id i27so8250218pfk.12
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:40:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=dcNOnkZ3QNA3naQZL2QsN8O60WJ6liuss/shdVWzI/w=;
        b=n9IPrdjjQHxHyQhnYVlMB2zovBCxSTWfBB9+e/J2VSLpavqqmVUUwCyVq1CBzqaMZ7
         PSkB2U0bYgbt6/Ys571/NDW23pDETsB6R+XuF1njUbKjZOyuLIyFo17M+hlMhefQf05M
         Rvn5SDGTYqNTyy7myxgbQWamowzf5vnZmUV7fjWmF+EODMeihdRIJUDsLans3mYLeIrH
         n9QfTQjhAeYL6xilOjmHdubDfQUJG+3RZEvvXz/hUdj1BwTyD83dYcb+8W+yZ39Ev1sL
         22/qkuWZCe8mZ/8hgwwMqs8BjThSD1QA5dz1bnLde5vrPucZWnV8Pb+GYQhttptycYrv
         JlQg==
X-Gm-Message-State: APjAAAXaQaBo/sFqTBBdcs7sdF6yAymHTM5oXuWvQxdQVoYCRp2TFGOF
	Lhe6NAK66mWEXjZb0OicbvmQxk2t01tDbvO0NGNLBQYI69pPJX0yWiKw1BLeM0yGZzgMiSBaSaa
	8I1YI9wXiLdQQ/LMkw5an8Gj0McfWvCbsgeMYWDlAAWiXbB47rCTCU7W7yp7GbqJf6A==
X-Received: by 2002:a63:5045:: with SMTP id q5mr22109431pgl.380.1561963251347;
        Sun, 30 Jun 2019 23:40:51 -0700 (PDT)
X-Received: by 2002:a63:5045:: with SMTP id q5mr22109388pgl.380.1561963250646;
        Sun, 30 Jun 2019 23:40:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561963250; cv=none;
        d=google.com; s=arc-20160816;
        b=jjvD5u5S5QiwutH5LlqblhqFsWWugG998L3CG6DQA7B/i5xzab4mIf1HFeHRBFN1a9
         cX0S/d25cr7dPPZ4kfZKx/zOUO7+qE3xMeMsHorKhHPaP4sM+muqo1+CtuprxDqVSiSC
         C66Y9AQT2t2RDtmE0+VcutoL8nbNtu5QKJ+wUMfdUk/vp/y8TXpm/YxM00jhznCBM+60
         wlY0DmPSYGOVoAWcsUmhSp6s0d8+FizIKNp0elVddH5igFRZyogcJs/DYyVyCh+cfQjy
         GDCf2irP9cQVoPGKvSOspJhArFXplDEFqK7SbNWBDJvXEY98lfBEhMeDYoxNiZD15SsU
         vcaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=dcNOnkZ3QNA3naQZL2QsN8O60WJ6liuss/shdVWzI/w=;
        b=MHiqSomYZuMCk2Zjm5hQ0K41l4+q4H/1Hg1OOTgNiweLsvy32CNgNZJ7GGym2dqr2C
         penI46FboOF3TrFhneQhcHbAuSW3/aXo/x/gi5YqK2co/JU1CtymDwg189RvYUHtrwaR
         5VcPz481Aaf7V0r/xU/MrpFBoonTN4DU9KFMvU7GAhobxqIX4WMnJ33VMEkfa71lDO9b
         9QoMCJ6putx4UWVP0YOGBFxl/YyX6yy9P7CBvSx5v51xhnOneM2yUkPfFpfWhpwvXmJr
         tXph78S0nhh4OrDL2Qi7VBWatYoE920dRTPoDSV4ha21hp/CPTlSWBwAVoz7Lz0LvPZi
         4idg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jt7i+Ah0;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor4353639pgk.44.2019.06.30.23.40.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 23:40:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jt7i+Ah0;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=dcNOnkZ3QNA3naQZL2QsN8O60WJ6liuss/shdVWzI/w=;
        b=jt7i+Ah0OIALx3FcRZ1UZkdX1H4ILpm/ltZc9KwQYbH8WrH3GEdinTHq+ex7/HsTed
         Q/DFlt5PofGsqai1Az11oYNvC8+cxbsQJXJx40MYtNrrkVLO3bvbYJT8wLGxeNRtOg+o
         57Hf/eY+JfZUT3NpcNl6/8Uk+X1AO8MWtOT3zpnCnacQdmAqcwOrmxUTuqxdZ7RhEzqK
         Am48lIIHnwHV8AfSk/jpE+HgXctcEK5PWZhSQXmtFvkQPkQZ3BwTSuM3AfroF++KSYjC
         9/BpKeJlEHYoI/ciZKoAF3S3Fc7bM+QF/p7hCLb11IzbCjyKkltoxPZepQ/YfMGX1jkD
         GVlQ==
X-Google-Smtp-Source: APXvYqyhm6G/Dxj/LNC8ofHNrlWkegS32az/Q37ZJ9wniqzmJWd0cS85z1rpS5JiVW3uLe2ZPBrYNQ==
X-Received: by 2002:a65:5248:: with SMTP id q8mr14304334pgp.259.1561963249300;
        Sun, 30 Jun 2019 23:40:49 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id x128sm24238285pfd.17.2019.06.30.23.40.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:40:48 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: "linux-mm @ kvack . org" <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	"linux-arm-kernel @ lists . infradead . org" <linux-arm-kernel@lists.infradead.org>,
	"linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH v2 0/3] fix vmalloc_to_page for huge vmap mappings
Date: Mon,  1 Jul 2019 16:40:23 +1000
Message-Id: <20190701064026.970-1-npiggin@gmail.com>
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

v2: change the order of testing pxx_large and pxx_bad, to avoid issues
    with arm64

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

