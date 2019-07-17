Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D02C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33FF321850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="leC/Gb3q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33FF321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C53136B0003; Tue, 16 Jul 2019 20:15:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C04346B0005; Tue, 16 Jul 2019 20:15:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF23C8E0001; Tue, 16 Jul 2019 20:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEB46B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:15:31 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id h67so18118152ybg.22
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=QsS0ZqN4YggOSSwkzcpaGSaK/G4QRt1uJsrCicwV7Ig=;
        b=ayTNAJjM7ZGGOQYT+K+R7HsI3NBKoiYec57TLAoJ+BriaWv/cevBBxXYTbrKfaByQv
         ClL2itgTCM8lfDBni9/kicWECwUJRDpJgG4uBjmd8692hRMpRIJfakzTjHoVNr87+ibM
         uEKEVSf7YlaAfsEiVODxFjmop/Nomo3q1yzznLqfT5OaZUHkwpNfaYyImuPBqOTUYpxQ
         QK9EYJb6T+QkY9y4zlByoFxSCA+LZqDrIjY35UgZtn64kDuQuwSUjsYJSSs7VUiffcTg
         hMLpNL6Vjl4Oa5KvVmWRj0Dm7Gx5YbiL+u9x+3fxD81tBNtFPmwoASZIaSyWs2WAciNT
         QQwA==
X-Gm-Message-State: APjAAAVl1JQGdBRDX8tBG5jsYeSgNzFEfYiUEnvsNXjzgwoqoBfdl4fm
	BvF1RrqVBPFAvr6kGnUxEp5w0nyvwLtv49oOLIuV0cktLojKZF1ivEx6dx2a6UIguAge+ippCOW
	XmPr5XqneTnD+yMziK7l1DhH21Db63Zrolt4vC5R523IoADfatBG7H352Co6txts/MQ==
X-Received: by 2002:a0d:e1c1:: with SMTP id k184mr21827065ywe.153.1563322531249;
        Tue, 16 Jul 2019 17:15:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrSvZR36O1Lp/iTnMOj0ZdhzRBeg/WiDIZmLBm3vp8kVts/o3221mXdbyk4m/NktK8V+Vj
X-Received: by 2002:a0d:e1c1:: with SMTP id k184mr21827040ywe.153.1563322530670;
        Tue, 16 Jul 2019 17:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563322530; cv=none;
        d=google.com; s=arc-20160816;
        b=qwg87sWKwYT1uVNz8fcPyfqRM9mzn/nFNP730qZ8U1YrLXWeCgcXrwUfJE0mqspSIV
         1FsAYlupwrCqrAxGO8eQKtUuyXp4M8Y5wZEMR3FKus/GGlHM1zHYYO2J9hHoeyYqcNrf
         ge4flZ4ZYUtE+8zR1OPdjKx3k7+r/+bget3CSa2OZAJbfyR5zmvGl4xHRN+jOXc0o2dI
         gksWQVJOGzAeCyUmGuRLw+7Ln0Y3KPjn1Usp0QFgySVUO48Q5lG5QTPUGEwF3vj7OR2m
         EtGD7QYnRI/JFdVh/ZrODo7b60mLP+Dcv9t9jEoJMEFUManwrqIMQhqAqlVaV2QDGIZg
         D/UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=QsS0ZqN4YggOSSwkzcpaGSaK/G4QRt1uJsrCicwV7Ig=;
        b=B5s++vQrtKlbhvQ7lLDKNxQ2S+0c8FD/adEgp4w9YWwP04aOD87RfJ8Daqs9UhUcT+
         0hrRMdnp6njSne5MwML7d3jUyUm8umsCxsH66bbKHr8fWQ3c03m8Kq+4thp3XdtUlR0t
         YNSjsQtG8HaRdrcrt7/99AV6zPp40DNr2KdNITg+OV0o65vTnBetLTfUbip9/oiTUq1R
         b7YFw42orUfmIaPlFqyn0MfsUDcsEU9h2hKibj5UB5n3fOgdHoAW2xQ/A8M88qIjFjcT
         tuy+JLigGfgwTZq1OwlKyRtko/kiV3wzx0Jg0/HQFgwaWfVKAb85tZDKkPSvW51OCgNd
         f1dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="leC/Gb3q";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id u194si8884178ywu.179.2019.07.16.17.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 17:15:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="leC/Gb3q";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e68a80001>; Tue, 16 Jul 2019 17:15:36 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 17:15:29 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Jul 2019 17:15:29 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 00:15:29 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 17 Jul 2019 00:15:29 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d2e68a10000>; Tue, 16 Jul 2019 17:15:29 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 0/3] mm/hmm: fixes for device private page migration
Date: Tue, 16 Jul 2019 17:14:43 -0700
Message-ID: <20190717001446.12351-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563322536; bh=QsS0ZqN4YggOSSwkzcpaGSaK/G4QRt1uJsrCicwV7Ig=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=leC/Gb3qxcTdl7ZxhD/ykWwGw86krGQRaZO7OGchr2aUxHZbQW/aj6ghYjKJaB2sg
	 LN6dtU9KfwqXAhpso+OWUQNKC6cFk18ZRuZIGgr/EGOvWAdmnylyUg58D3H5vjfvGn
	 2FAgd6tdTzVwWKB/uTtaEY0+pfsdaMKKJLZgbSedqpka1JJb9zIfa7ooPuLPKnEYyK
	 yzYjLrl4H8kwhU3Q3YBZ28rIzMsv3YfeAGBrRijqQu+amFWj7kLzlLhiSc1sgqNkfl
	 8GW7bQfebpC8hnNsFLRBGLDCDPTkhXEoXjkMujCpSGkUy+27tEFrSY+YZQY6bLFB1I
	 K51ZVi3Q3NZgg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003731, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Testing the latest linux git tree turned up a few bugs with page
migration to and from ZONE_DEVICE private and anonymous pages.
Hopefully it clarifies how ZONE_DEVICE private struct page uses
the same mapping and index fields from the source anonymous page
mapping.

Patch #3 was sent earlier and this is v2 with an updated change log.
http://lkml.kernel.org/r/20190709223556.28908-1-rcampbell@nvidia.com

Ralph Campbell (3):
  mm: document zone device struct page reserved fields
  mm/hmm: fix ZONE_DEVICE anon page mapping reuse
  mm/hmm: Fix bad subpage pointer in try_to_unmap_one

 include/linux/mm_types.h | 9 ++++++++-
 kernel/memremap.c        | 4 ++++
 mm/rmap.c                | 1 +
 3 files changed, 13 insertions(+), 1 deletion(-)

--=20
2.20.1

