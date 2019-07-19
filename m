Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF73AC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 876B42186A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jxQEAVW9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 876B42186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 155D56B0005; Fri, 19 Jul 2019 15:07:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 108046B0006; Fri, 19 Jul 2019 15:07:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01E0A8E0001; Fri, 19 Jul 2019 15:07:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4CE06B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:07:00 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q79so24406659ywg.13
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:07:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=QsS0ZqN4YggOSSwkzcpaGSaK/G4QRt1uJsrCicwV7Ig=;
        b=nsTGBcQW/gjMIMOpkC5qQDRRfa13+q/s+ZKvUrCRjWBV4Qrkiggm1FLvZeLmhsTCMv
         9ywaFRYUQAbSOwvsGD1jmuY8Knq2DWXDTgZbHkTvB6iIh5JPtwnLH6hekTMQSlfE5aoM
         30/ScrJM/gi/e2fdMwatNrjVzyM5iAzORJrRPAN9n4HXya0ltoC/3VByVSTegHqp1XWH
         TnG+7PkXf9zuGw9nOHv3YXEV9MGLUM0V645gRd/mYyfMapX7PAh74A968cUYuhFWQPo3
         Ge4Wq/E2YzYPR2G5VY8dWHMGV3/370tl4eqR3Vu4xEevROrCJAPOTaD5FvPFd67d36XU
         gQXg==
X-Gm-Message-State: APjAAAXkSM3CyGui3R5Sre4yiVqEx6WlcsOC8xNkI6wNnVFMPxnd4Imn
	kkx+lwarlVtRWWDsqYvm+OkY69uebU6ReAhcLtQ3Qop3+FvAy+UDDW3suXeZF3vuaO5O9JRypQu
	09CcIWKWOZyh7I/DXe8+FoXCR9CHSg/yI7dY+10/o8tG8Jh2Vbf8rcVtmLvmeUBl/Vg==
X-Received: by 2002:a81:4917:: with SMTP id w23mr32449630ywa.178.1563563220584;
        Fri, 19 Jul 2019 12:07:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHsG1uDhiQAASzO8FzQSpH87HnMeo9VKj65PVA0i6dG8cKmUHt0IQXfMYceAKee4uen0ka
X-Received: by 2002:a81:4917:: with SMTP id w23mr32449584ywa.178.1563563219908;
        Fri, 19 Jul 2019 12:06:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563563219; cv=none;
        d=google.com; s=arc-20160816;
        b=HND8OpLqykSOMK6VQXlQlr2ub7ujKeaYP8OT9Z5oUIVAnaYgylxXqyNAwCadQ77RAS
         r3q15nhbxy7UzSfhBS8soCIarWSUzwWzDWjoIOrgEIH6tV8hbhOFy9G6msY+QBdJfySu
         vwALPRRlOEO5e0UcMIWdcEKNW0a3fNnqwzHh681Z/bFIht9djDuQuuWoOaUvxIalxS99
         OsQxgOo7s7W5O5SjFjX2EG+TvTRWL49e217f8/5Z8WuW0Hzpyc9v6SjzWqQmdE0Vy8Bs
         yRFRclqxt0CoR2pPpFJ53RKP0RlqTVuHjzKTVKluqzkfNVjKfGXQvwb6qZXYd2rkmj0D
         NB1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=QsS0ZqN4YggOSSwkzcpaGSaK/G4QRt1uJsrCicwV7Ig=;
        b=w6RWS252JH9rHnEIE1Svy5LVCkVbfqP0sUdY7UufmRE7U/rFq74aFm+B1B4m4hHGyD
         YwYU+4Ol9SKP6PfmNMeDCl/EFCQmNhsiaYQ35/5caq9JcRcnXBlvrRHZqOC1w0XcpsOI
         nlQ/ly5jDxcVFU28nQJrqJu9B/wRwcPoGfPwxyzUj1yth5GXsOVou0vbdw2das1YaAFo
         LfQL/mMCzJLmZ35zGsZeBJLTkZSFVVTAv6sHopq89UeNua1eR3pDRttfvkCYjzznz4MV
         imNtqTOhQh/XaDmwF8SlOID5Bf5XwIhxLsUpT+BCAB3I8fPuuxhjx6rnUWX5L+oZZhBF
         1PRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jxQEAVW9;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id c124si11729605ybc.220.2019.07.19.12.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:06:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jxQEAVW9;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3214d90000>; Fri, 19 Jul 2019 12:07:05 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:06:58 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 12:06:58 -0700
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:06:58 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:06:58 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3214d10003>; Fri, 19 Jul 2019 12:06:57 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 0/3] mm/hmm: fixes for device private page migration
Date: Fri, 19 Jul 2019 12:06:46 -0700
Message-ID: <20190719190649.30096-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563563225; bh=QsS0ZqN4YggOSSwkzcpaGSaK/G4QRt1uJsrCicwV7Ig=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=jxQEAVW9dL6wzzJZhi9oVQfu95yulOt+20Uvj544XLjwMiQF2QVwEX293Qs43kMoS
	 4Vso1R6MQwYZIUgf2p1UD0BhTiYszqeVq93M0aNeGArCRA0EAGnU6mIwDh4Hy7ROmh
	 ymYxVgjQHBtZkADvjbeoVXPih7pWmzkC7XnJjQUHdLr68pryGeO9O0J4uEUPphuhjD
	 nNFSht/knyqL7UOJ6vRE4LDm2AMiTgrYJVPm6GmFKmTj+1+AXEFwpPXIFGEb670h7c
	 jIttNprxT/CtiaFP7+TrcdMm1fYvhVD/p19AVkGdnVLwB7E+YUhgFhCZn1xsiKqIg8
	 dE/I33qUqnaPQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003585, version=1.2.4
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

