Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29B1EC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBDB8206BF
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="LwG+Z+Iy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBDB8206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 793596B0005; Mon,  6 May 2019 19:30:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7440F6B0006; Mon,  6 May 2019 19:30:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 632BC6B0007; Mon,  6 May 2019 19:30:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 307096B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:30:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a90so8056051plc.7
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:30:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=mta6lvER55pJmKi6odFyptVYcK5PuHqcwXSPKJWVRbY=;
        b=l0KT8b1dhv3qZygaXKiQY6dBxIoT0Pn1XtA6y+/bZ/0HWWek+/GAjmaIcK6f8Sz1rV
         QqfpfcZoGR9mllbjAOe4hUt8g880/Tg/pnKV9f0V7jVOA+p7Vkvbd4jbcDfm/2TRdygz
         d3kgaY3fQlvox7oxt7lMSBNbUfvDiF447g++JI4yZMYCqIJfwFHfGVKFG+Gq1n0DWrmX
         aAJypVtZa5X2+/qRnmO3bQJHmWzmS4CloxQXE97/QXUcA+eDnzuIFG2dxtgqaQ1n4ASn
         yOx0LLC+3crvb0g1go7zR1PjRl7EbO04EjI4q3r+wuq13BbXYyA/9HUIhXYvLLz+Tjw3
         y2uA==
X-Gm-Message-State: APjAAAUfoCFVOdWidzcz9gX99uOxwvStJSOX1oAFAF4uVPDo2q6VvqOm
	mifZ9bChDpLRqohT01PBifj+GoJ7msYROy+ZpEMyMRQmYZuh2UKzg3pZAP43Asgh9ubyvou2Zyn
	x0drfQCFG6MslxQ2HRlR6d0Q8SbZXDaXcPpu9RtS/QszbSzWsTyL8hPQxRh0EScntuA==
X-Received: by 2002:a62:b508:: with SMTP id y8mr35631078pfe.113.1557185426770;
        Mon, 06 May 2019 16:30:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAkPW+y3I3wuOlal3BoVDPenv2yyDUOaIQQJwigihQVBtvlPJ3OaJvmv6JrZwXU62HzXYV
X-Received: by 2002:a62:b508:: with SMTP id y8mr35630866pfe.113.1557185424425;
        Mon, 06 May 2019 16:30:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557185424; cv=none;
        d=google.com; s=arc-20160816;
        b=Rnf1CL/KCmupiSkR1d5Xm808mMYffx1ZIciIG3Qd6kFbfx/JxFISI3Jy6fRLDLnhYe
         p9hkII0L6D6/DC4UIt/nEyFvpqiwHZGcancfFVj4VegVcmy6eq6HaFFWZVWM2xpSQPSj
         2aA2ewbQHaUFmkHYg3OLQd1tesfPjT11UZcsoXZ0hckACodtsrG7x9wnE37tdbEWe8uG
         JYdEIOR1B1pGFF91cdZWWxmDpyFG3GVWwhZGdnva0LzeKErIwv5lIhG99d2yNYZ/fj1t
         AyWTFXL74XytDRQKaCwMToX7Igz2V4ZsptsgrS1ZzO90qYvGtoz7rq0y5szxg3d9Ev5R
         3x+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=mta6lvER55pJmKi6odFyptVYcK5PuHqcwXSPKJWVRbY=;
        b=0cyHNxY/ZmjBH6LOiu5pMkxSWH2kadWvuSlteRxC5/hX45Fz7F+WuC09s1TOwKfvCs
         4ffQKYWfCJmoa5jwWnY6f8FyHmrgGr79Glh++c3FyCdElt4U8NC5V8DvHoSMlgk8W/nV
         PQ4XUdmgmvCq34S7jre++cNuwh9pwC7BabIiSHWd1ubIX+UbBGYaa8fWVg5sH0iDJYjK
         aY3NeAeZbkriZO2AlRLj68QHIjBJFchPTTTSbZ1Fa8MyOPfsupxjt69tA27SPMgMNR2D
         vOsgWTSvFDPXu5uQLpGoHNq98N4+8ut8HLIFbtbpENX3PFfKNVwFPwMucpgHFspAVX+A
         OBqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=LwG+Z+Iy;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id h185si17819184pfc.241.2019.05.06.16.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:30:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=LwG+Z+Iy;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd0c36d0000>; Mon, 06 May 2019 16:29:49 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 06 May 2019 16:30:23 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 06 May 2019 16:30:23 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 6 May
 2019 23:30:23 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir
 Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Souptick Joarder
	<jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 0/5] mm/hmm: HMM documentation updates and code fixes
Date: Mon, 6 May 2019 16:29:37 -0700
Message-ID: <20190506232942.12623-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557185389; bh=mta6lvER55pJmKi6odFyptVYcK5PuHqcwXSPKJWVRbY=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:X-Originating-IP:
	 X-ClientProxiedBy:Content-Transfer-Encoding:Content-Type;
	b=LwG+Z+IypCu/9CAOnvaVu10/3zZeMNdtntNmkP+Wy9zH5AuV3pgXklp6x/VXDiVk1
	 pYvpjypSdkVh+WcZIQl+58wbS96p8vDHAzxD53/XRb2U9b4AlIFACrbdgXXSMbmnvl
	 xpdZT8dE2iQqRPBgOxKL0bTLcpPJPsvtIFtqXSRzkEDD4DGXZbqaX07jX+hb6GIAQN
	 cxBONRH7a7Avcam0YtnIBN7ysG+Wky5nPcDfovDeHcqrKL8eg5BY/URsbjy5RxzqWp
	 Kkhxv8o3+AM1C6szZ4TDWZ846ybHWGxTpOPVMHMXGwT92Iqani0qWBab2YbsrOO5D7
	 Wknzcx03wK0qg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

I hit a use after free bug in hmm_free() with KASAN and then couldn't
stop myself from cleaning up a bunch of documentation and coding style
changes. So the first two patches are clean ups, the last three are
the fixes.

Ralph Campbell (5):
  mm/hmm: Update HMM documentation
  mm/hmm: Clean up some coding style and comments
  mm/hmm: Use mm_get_hmm() in hmm_range_register()
  mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
  mm/hmm: Fix mm stale reference use in hmm_free()

 Documentation/vm/hmm.rst | 139 ++++++++++++++++++-----------------
 include/linux/hmm.h      |  84 ++++++++++------------
 mm/hmm.c                 | 151 ++++++++++++++++-----------------------
 3 files changed, 174 insertions(+), 200 deletions(-)

--=20
2.20.1

