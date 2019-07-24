Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D79F0C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9551C2189F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:27:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="mHFm/5BS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9551C2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BD4C8E0016; Wed, 24 Jul 2019 19:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36CEB8E0002; Wed, 24 Jul 2019 19:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 234B88E0016; Wed, 24 Jul 2019 19:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id F21E78E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:27:07 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a2so24192523ybb.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:27:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=gTLfLpBBgzH14pN0OishW6D/G2zPoxenwkGRe8J45rs=;
        b=PRtoxlK0jsEMZFJmvtRC7XjlYJc1D5mMDBZ+x4SqXoTEEYz7K73Mz3FXD7NZhILnWn
         fv0CPMkT/pnrlQvqY2oohsqhK9O6BYCMnqcwSJ0KfLbK2JdcUKfyIRJABFGQWuJ13pBJ
         esJJzNCT9OxX8aPur1x9t6PYdsuhdqjTlG8XxyPyuzIB8V4zxGJca9X0FJxah/k8T0/F
         YHN0ymr3aARaOeQ6eh0R2pZkpafbGGOlZVQDCusDOwTkofjhBXcJuwzlDeDZrMeUtZly
         0vFkho3gF8O1x6AZ2n/3T+8pgvAhBP25LzMDhl1+N8MlTHhihok2RAfEU8sYVt8eRXio
         PLOA==
X-Gm-Message-State: APjAAAVlzrwH84c8jj3VgbqwKmE3clRtGqHPVJ8Gaem1432Z5Gfb08oh
	8Ma1Kwu49iua52n2RBqZsse44ttrcBzprY9yzj/cGVMyqtNmq8Dvyt5HbfD8eRMhSPNbtm7qO2g
	LlhWbDg+yMxYFhTfddRLhs8k87gcUKLFlnVJqiBGcuJxtVqeXng2CM4cUYTc9Nb+zDQ==
X-Received: by 2002:a81:3b8e:: with SMTP id i136mr50143309ywa.493.1564010827772;
        Wed, 24 Jul 2019 16:27:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpkZfaVFrjtHLQtZ4kUalqCq/Zo109izrGHpt7QTzT6gv+y+KJJBXOBM2yRkZs1qoQ3TWt
X-Received: by 2002:a81:3b8e:: with SMTP id i136mr50143278ywa.493.1564010827070;
        Wed, 24 Jul 2019 16:27:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564010827; cv=none;
        d=google.com; s=arc-20160816;
        b=p4jVEnxgGVB4ZqN40nQORpMkz5ZGMBHeoRYv2wA7DRDgpLYDRXnyUXbduVFYo1KZ7L
         GoOEy93A2TatI+zt6jDrRSDYdxXhIZnF/U9w9Lo5eC/gs2EyD+kehylOlFds7D027rVO
         Z215/qO/ujYtJaWqUPiNFSuFq5SNWeNCV4Ec8+OWe1EfndHb1Qtg1rGLYGuwDsGn1WpF
         x5ERTeWanFbNAlDyBWP1FRQXTblaJFf00qEVo90BnFt4Ds2T5e4ySuF2MPr6hvGiVMXW
         wVouWZY0EvPQSRgCMBYrSgYfwET4UrXMCZltuwZtehWOG8R03X9WWdr0qO0guT0YupCC
         +QIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=gTLfLpBBgzH14pN0OishW6D/G2zPoxenwkGRe8J45rs=;
        b=I5WDinnpTbu24VuJsjB2s6Vnzqya0Y/qk8COwXvYrS82HPyUUIqQq5Vf+2dx53luVA
         kqv0HhpXImNZkDRBuZ+60XuvJOvO7slQpzns5iaRzRrd4iRUKGrQMQ13hz8H4HCoA33h
         4+7xpWYTpSDL/3RfKNhXqxEgUmQR7QxJtlEAY2iJNIduEZpPt+zPtANhui8QfHzxAJiB
         CS85aJyYOpuG09wCIZfPk+m2rvt/cUYcqKBHgSZZvdB9LylBcg1Eaof+ndKRC0BmuaLY
         kR+nVkUP+sUFisV/YNhpCqLG3FjrBPWS51+m2kf+WezQoVWz+HPirdWQWrpeLQ7EsZJP
         /Aeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="mHFm/5BS";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id y73si13409058ywy.7.2019.07.24.16.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 16:27:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="mHFm/5BS";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d38e94a0000>; Wed, 24 Jul 2019 16:27:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 24 Jul 2019 16:27:06 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 24 Jul 2019 16:27:06 -0700
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 23:27:05 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 24 Jul 2019 23:27:05 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d38e9490001>; Wed, 24 Jul 2019 16:27:05 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v3 0/3] mm/hmm: fixes for device private page migration
Date: Wed, 24 Jul 2019 16:26:57 -0700
Message-ID: <20190724232700.23327-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564010826; bh=gTLfLpBBgzH14pN0OishW6D/G2zPoxenwkGRe8J45rs=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=mHFm/5BSNkpiIizmFlxJBFlZ5AY3WiRyFEePDr9oWQ473aDpCVLOrRoB6nx0KwvjS
	 HYxtHV5bRdS23e6YHjzo2c+4shRrFMHOLx4DXn/XfeN/VXzFHKHJ3KcmukN5izfPyb
	 pHTAlnOE1JXeN8ZEnA8uY3CFSvD4vUReVd21A/cehRYjo7rr8nZkwkZRgNDX5nKtok
	 smxmGyZ/IUUAmmt6AVIAeIi1avYMjafvV4pQGVOwa3mtrI0if+Hf3GfcoNiNEivQgW
	 LI/+XnVIJppguZ69lKQjgs9cAKna0rPAqcb1junJAQrye8vz3mCYu4dXF/xVJyE7xv
	 JySHepvCjAlrA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Testing the latest linux git tree turned up a few bugs with page
migration to and from ZONE_DEVICE private and anonymous pages.
Hopefully this series clarifies how ZONE_DEVICE private struct page
uses the same mapping and index fields from the source anonymous page
mapping.

Changes from v2 to v3:

Patch #1 is basically new (like v1 but with comments from v2) to
accommodate Matthew Wilcox's NAK of v2 and Christoph's objection to
adding _zd_pad fields in v1.

Patch #2 adds reviewed-by

Patch #3 adds comments explaining the reason for setting "subpage".

Changes from v1 to v2:

Patch #1 merges ZONE_DEVICE page struct into a union of lru and
a struct for ZONE_DEVICE fields. So, basically a new patch.

Patch #2 updates the code comments for clearing page->mapping as
suggested by John Hubbard.

Patch #3 is unchanged from the previous posting but note that
Andrew Morton has v1 queued in v5.2-mmotm-2019-07-18-16-08.

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

