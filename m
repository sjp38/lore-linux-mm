Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2D42C282E1
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 01:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2586D2081C
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 01:45:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K5N+Xnyh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2586D2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F1F76B0008; Fri, 24 May 2019 21:45:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A3816B000A; Fri, 24 May 2019 21:45:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36AEC6B000C; Fri, 24 May 2019 21:45:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00E916B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 21:45:28 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id cc5so7048743plb.12
        for <linux-mm@kvack.org>; Fri, 24 May 2019 18:45:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Skm0BooE8bru2DUWoCfdtPEN/f8K6576ki1g23+28oU=;
        b=LmcjQH5uURTsKJT2dFVaG1w7180yQ8el2qVuy0DeaUqNXj8VpMYsOQCtURwTvPpolG
         uBX/hChbLIhxhpUtRTrPVFyV0lb2hAB6QHhsIKIpjM4V+YAOokuUvaaHjK7t0EpPTc65
         fukis4sKychR9YnxlADHvsMYt3SLZAeynFmdHZOB8nfum4Roqwx9KOZ0syJR5yCVBg5p
         HLTP0bjoVWOrZAOF3PSzX9DzBVuwDPezXPoM6R9Wd3ppqoidmlyHyhA8vHViPoni0oTx
         lkSbtWaFC/zGGikTwwxOPQDB/lJWg3I9xBPe7pKjZsjaklYUKNtAb3s6Gx/ShAdM3ztT
         RAxA==
X-Gm-Message-State: APjAAAVFVGGXCstZ12QM0DAC+PiOskXkvv+y54q0Ul36e7axkdzNFKZg
	TIeQivClNACxhCNqzkl77kjW58rNqK8gtJLm/g5mBBtDAia3La5iNhiGA6mXvvyCtV/guvOMVza
	Rt95KB9N1EHzCnXF/YeF8ft3kB6xJUwxT1RzhoVlBxDLiKWOKzCCJE2lpKjNsTop+2A==
X-Received: by 2002:a17:90a:3848:: with SMTP id l8mr13691780pjf.142.1558748727546;
        Fri, 24 May 2019 18:45:27 -0700 (PDT)
X-Received: by 2002:a17:90a:3848:: with SMTP id l8mr13691699pjf.142.1558748726363;
        Fri, 24 May 2019 18:45:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558748726; cv=none;
        d=google.com; s=arc-20160816;
        b=YftFSquSBLY+GimZqICdqmBIfbfiTfbqqc/LTNXPkZIUfj/VHMCF1RZ2OUbzCYYbGh
         tgAb7yhcHz159JOeFAiCtnjztm2XnF/i4RMdLQDN4YWpEM9XPj0NR9kYlboUyH2q7M0E
         BtBI1h+gcG218BC//plsyZR+oelJOn7wDaLkvhFfQ0enO57m0jRdgoSvhRRNDphbfiqU
         H6u0OHEJ3pkJwqXQO829QFAsNBoW3RbXuG5lOMDYo+V+I0qB0b7Luh9OR+ZrZ2xKKdvu
         HoJocjQdhBjLBhWPOHL0N98nKUts89m0pei1O0UXWi0SYZOSfv/QXOTG8FnDuPXc09ZK
         xFWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Skm0BooE8bru2DUWoCfdtPEN/f8K6576ki1g23+28oU=;
        b=v9b8uPeEzYcRTNy1ioE7qaMitkE7tZ/c5/n4MjERWserP4kbxX0nailG4zBdx0mFR/
         xrm4n6UVUPLJON1kgRIGRq98z0pPtc77UHEdXOcUNDrbh+ifK7aHo5sQhujP7DwJHLBt
         RTO22+Hoo7EFGh92mgGZhSSx9To03mX8EmPM8SYTd3pHi/w8olCSPs/CsX3KJ7shMtyl
         MgaIxcr5SoidBmQgMZneoCQeVcGP64/fwolRxHg1QETuQtmRR1bgh90IMKZncABCbng3
         fsDfmfKlsK2rdKwddtbtUyJT1poxE3V2cejr6oCu9nw4Xvhl5Tl5WalV/kw8gkYEnKC1
         shTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K5N+Xnyh;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor5340370plk.55.2019.05.24.18.45.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 18:45:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K5N+Xnyh;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Skm0BooE8bru2DUWoCfdtPEN/f8K6576ki1g23+28oU=;
        b=K5N+XnyhqbWmWhUFvHOx/ERUs9BUIfMuHlfBr6gTOB6CFeaYPRdw4zcRM1nYTEHTOU
         xBoX1wV8yIbIWcxiaxJ3nG+vzjoVEjeR7osDiXIRft7fmyDpFasAhmzfHZvtlSf7KKVw
         pwvJ3/LmrBOBrGfkhf1J68H6E4w2H+AmDUMngEweiFNd8EdDYF1hqRD68Y4BPN/VIyZg
         wrwtDwL/00b8fvLVUrAtRplkJJT4BzxxCjbLsBL+JbOO0Kh/+refSPYawJT+HI6SOFHn
         y+R8Rc47sHq9eihpvoqo1aFOedQPZFFGUm100G1iExkf6ax6Lxju2syMwDIScZTO9kTd
         tCVg==
X-Google-Smtp-Source: APXvYqzPm1svpXwxu1qbq8IVYDweHwhOwp0Qkbxn4JKbwdQNGlhYtqaAT122dNOctLZcYWMWiq2KDg==
X-Received: by 2002:a17:902:aa97:: with SMTP id d23mr110476812plr.313.1558748725891;
        Fri, 24 May 2019 18:45:25 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id x6sm5441611pgr.36.2019.05.24.18.45.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 18:45:24 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v2 0/1] infiniband/mm: convert put_page() to put_user_page*()
Date: Fri, 24 May 2019 18:45:21 -0700
Message-Id: <20190525014522.8042-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Hi Jason and all,

I've added Jerome's and Ira's Reviewed-by tags. Other than that, this patch
is the same as v1.

==========================================================================
Earlier cover letter:

IIUC, now that we have the put_user_pages() merged in to linux.git, we can
start sending up the callsite conversions via different subsystem
maintainer trees. Here's one for linux-rdma.

I've left the various Reviewed-by: and Tested-by: tags on here, even
though it's been through a few rebases.

If anyone has hardware, it would be good to get a real test of this.

thanks,
--
John Hubbard
NVIDIA

Cc: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jérôme Glisse <jglisse@redhat.com>

John Hubbard (1):
  infiniband/mm: convert put_page() to put_user_page*()

 drivers/infiniband/core/umem.c              |  7 ++++---
 drivers/infiniband/core/umem_odp.c          | 10 +++++-----
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +++---
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 ++++---
 7 files changed, 27 insertions(+), 31 deletions(-)

-- 
2.21.0

