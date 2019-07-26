Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9130C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7226A2238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:56:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YuFWjX01"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7226A2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2047A6B0003; Thu, 25 Jul 2019 20:56:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B3E96B0005; Thu, 25 Jul 2019 20:56:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C9C58E0002; Thu, 25 Jul 2019 20:56:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAA566B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:56:56 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id q196so39614647ybg.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:56:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=5+MT9OBADQ1SPlqa4lbGtzxIR+MyjShmpHu800z/6QY=;
        b=FjumHtkUgguCo7y3bcwchrokZT7jUUHd+w4kghNQpPN2FqVzlAp2LgeZrymzu8D9aM
         vYwN569sAZsJ8sjQqU/ec4LCmqn0J/th83wVqD36WVWDrJRVEcXEAdnxUVneKQtojoMV
         fnP/PB++Roixyl70yM/Za0l4UqZNWHezLlXS3QUkLz3I3iQY8UcG+tP5lPGj02Z2JyFt
         gbuNWFPPzz1sHwrWG5wLfjBW+i4Y/G3LujCJHc0SH02m/5PqI1ZEoInvgOHoXU9Jcn9e
         dHcnu6YamqM8duN3UVgWvaWqQta3kQji68c/nACU3xSy3pORpD064lJJDE5GdQ6cA9y/
         0RbQ==
X-Gm-Message-State: APjAAAVCdEODCf6L366TZnljxJQulLwx8XyD5+isl/EsgsGTmPa7or6/
	nSUEW2X2n7MYJMk2PPknzMudh0BBKh2Rl7wO/01fOi+RUbZrcBmzjNz2WZTQDTxVVf+Jiwzu7D0
	nr1/YMJpBtifPjgUQB5krAbD0HeTcNNFKEe28CGLBZ1LfV8e/+FaSr2g+T5y8p+ZaZA==
X-Received: by 2002:a25:42d6:: with SMTP id p205mr53470492yba.148.1564102616627;
        Thu, 25 Jul 2019 17:56:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUdiT4DyCOKD6y54ZoQQgrI61XVHF5v3cSAnD+byQFEF3nVErMhl9gSr6Rr6JAD9V2ghhF
X-Received: by 2002:a25:42d6:: with SMTP id p205mr53470482yba.148.1564102616090;
        Thu, 25 Jul 2019 17:56:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102616; cv=none;
        d=google.com; s=arc-20160816;
        b=h4xdIp8yODTLhVAVaOp4l0zDoTVlpn3YWyRLAjWmflvhU8nMOPOOZZnOC/eYD00ahy
         UGpvXXFWYMV4dhlGMVovvFX8U1xDD6ZoMWWZSYFZpUozEsEqvDz/Hl5PpvbkDbtrdRwn
         THEuuGobVVNyVbnxOICdLYW5Y2pDfWRERFR+ve5d3MRexCVtmhlHaGAH3HSYGv470oO0
         6wVpWqkeRAIPPPYPZOxWpYLi6Wu0HUwVVZlbcym5FmUP1EznVzTP/LEXUsuJ2v3oxhiz
         grmgm3t7EYjdODdt2E/ezm81lpcfAC6VyaJKlQPJJZJVBnzGY4Sp2ha0W5Meh01u9Ugj
         1YIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=5+MT9OBADQ1SPlqa4lbGtzxIR+MyjShmpHu800z/6QY=;
        b=sAw3D4BLOG4UXK7BvdrXO+H35A+B+Ty0tdnjPv787dBx+vsEDGaki6qr1MVNcGbA7J
         6gyP07QFyInr8v7fdODXPCvECTfw+HqQHXmwTiulPY5RDsWt6ogwaBZlFhiEahfZwkmW
         p1zQifrOrC9WZpSZtJGOdZaTgx3Ml7CEKXFr5Om6XO7tiNqshsLQUyKDmwpM/og4IEGH
         VFS51rVZfF8fa9gfAWDhSjRInRJuPU7TO1OjdVa8SYWOVFDxnBkgvqwk3XOEFaRbQgAa
         1AcvzBnnuf4ZHM3i4Yr32vJSmPRnMM7Vz+FqvLAC/0aTiALqJXFSsCfYJtV9tCxrNNQH
         kiVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YuFWjX01;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 196si17946493ywb.282.2019.07.25.17.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:56:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YuFWjX01;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a4fd70000>; Thu, 25 Jul 2019 17:56:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 17:56:55 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 17:56:55 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:56:55 +0000
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:56:54 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 26 Jul 2019 00:56:54 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3a4fd60000>; Thu, 25 Jul 2019 17:56:54 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>
Subject: [PATCH v2 0/7] mm/hmm: more HMM clean up
Date: Thu, 25 Jul 2019 17:56:43 -0700
Message-ID: <20190726005650.2566-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564102616; bh=5+MT9OBADQ1SPlqa4lbGtzxIR+MyjShmpHu800z/6QY=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=YuFWjX012+NgjLM9Bm4Tl9N6DrjrA2qBJ8XfMLtek1xIKcwAlW2zTR7ZBopoYELCY
	 qq0y0XlrVhbGJ6bBZHliXVLop7L0xtDhK3U8CINQGLzvkB5pD+o97C6FGz3F6w/Y+V
	 7Aw/qj+1tk977HV5Pp/V8fHOawl344UIfDB5VagbgnrLiYsock1yoxRDIWMnvtcIiV
	 7yN6j2R9JWSd4G+IyKVyK7+jmk/6h9RlvhGC+nkCxxT7SIa8eHwU2SzryIf1Ql82Qa
	 L3F083tLofkQ7gF9r/Wy3jeqyW8Q8xLCmPBJzzzv7BUC1SgdLrE5m0tn2mPCebXchj
	 lGqghDh3XCyJA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here are seven more patches for things I found to clean up.
This was based on top of Christoph's seven patches:
"hmm_range_fault related fixes and legacy API removal v3".
I assume this will go into Jason's tree since there will likely be
more HMM changes in this cycle.

Changes from v1 to v2:

Added AMD GPU to hmm_update removal.
Added 2 patches from Christoph.
Added 2 patches as a result of Jason's suggestions.

Christoph Hellwig (2):
  mm/hmm: replace the block argument to hmm_range_fault with a flags
    value
  mm: merge hmm_range_snapshot into hmm_range_fault

Ralph Campbell (5):
  mm/hmm: replace hmm_update with mmu_notifier_range
  mm/hmm: a few more C style and comment clean ups
  mm/hmm: make full use of walk_page_range()
  mm/hmm: remove hugetlbfs check in hmm_vma_walk_pmd
  mm/hmm: remove hmm_range vma

 Documentation/vm/hmm.rst                |  17 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |   8 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |   2 +-
 drivers/gpu/drm/nouveau/nouveau_svm.c   |  13 +-
 include/linux/hmm.h                     |  47 ++--
 mm/hmm.c                                | 340 ++++++++----------------
 6 files changed, 150 insertions(+), 277 deletions(-)

--=20
2.20.1

