Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4054C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 850FC2147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z/ReGytP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 850FC2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D6FB6B0005; Mon,  5 Aug 2019 18:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 186296B0006; Mon,  5 Aug 2019 18:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 076106B000A; Mon,  5 Aug 2019 18:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9EA16B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:20:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so47095037pla.3
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:20:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=G0gFHWZTLbSduXOaMLchOdcBu5BZUnGvKngNJx2WzYs=;
        b=Bx66EAH6XYpfG79lKhFgKm+tmdRTsXf6Fm7yD/4bX9suBqEOz6cFGvJZcTCKYL6kGa
         CGFHWQgsMJxuAsHPV78y1hSujxq/ZZkVXpFDo6uUu8TZ5vyyMF7Umnj16kWX0ZmEZZCr
         BpWrICup3DTnKGC+Bq0geyaMRQnwAfQKFnqh+WX5YYKaFU/cN5ywfRXzq15G+eB5uHBa
         Kww4L0fb0ES5i7sUPr7MFroCQh3vkUbFKiIdJ2VBr9Bd8+pjpz1ZvdztmMvQihFl6iaC
         C78MTpz9XW3ikf7NfnrN7Uv06JahySjidAD6VoGP1N5KEjyeQH1xowWKz1JUNSzcBCOv
         wQzw==
X-Gm-Message-State: APjAAAW2KiIw2IkiEHGKDX2eFrMIccNQF3ZhOxuMZfTE0Jch75AILUGW
	G/uCYlkqAk7R5wfpC8N/jLqZ5elnI8EESFrw0fTUcDHN0wVqBsTz+syTrgM+lKWb3M+S54MO47L
	arpPC4IL7eiAoon8LYowPFphWOCIznU5c/8950Y7N/tq2LbCm1r5EekEd4BBdCLDk0w==
X-Received: by 2002:a62:ce07:: with SMTP id y7mr294448pfg.12.1565043622510;
        Mon, 05 Aug 2019 15:20:22 -0700 (PDT)
X-Received: by 2002:a62:ce07:: with SMTP id y7mr294413pfg.12.1565043621893;
        Mon, 05 Aug 2019 15:20:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565043621; cv=none;
        d=google.com; s=arc-20160816;
        b=v4SVefgd2or3UuvpRtz8jGrO7/cXs/B4OP22g8XTiTJcjyjBLCXuuAh7xKJhkWBK0W
         Y2xWb7kNdUQv9rbLxbCEt54mgJMOyWUyEjAgUg9zGy/sidLJu3OOpWrEqouzX/8rwjSc
         /08cRwCzNFc/At47OXu7p69A8fLvMtW5XwgSPNdYjbJCmPsHKbhPSWrTCxK9a/Mq3RBF
         fHYNVKzfWDN3yyZn+mavz4SPtIJ4sGTuEat4DklxcOfnBSmeok0LYvO6s4vEYIweEmhv
         kCGP7C2ma4LduQsFej0J2Wr6NgZxp1/3AplBs5tDSwSSp2WfP1TGC15SDSQ+8HshLAg4
         7QBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=G0gFHWZTLbSduXOaMLchOdcBu5BZUnGvKngNJx2WzYs=;
        b=mCPxdvrH15eSe+7zGNiofHtBj/Cj6XtUGhI8rS8jymvaeYxQx6EQ8YljkEW5Jxz3Ll
         wVJ5+XjZ8Zsv9JbxiwpdkPcKkXaOwO0h7jvvvqGqiVbs9E66Z6N/MqgOWk/GLikeRRYx
         sqiwj8ssKX0c6Y4+XYV4BP55FvagDRd89QaoRqRifka8AGscOvtFFLtmgNMs0DbZ/nEX
         P3dVAVDmb86/uWUxIeHiXPC8rE9hPayfxYDLnUsIeNzETxSTvnhjPbdb27oXU3OANLlV
         wcN8N+T+eWkW2Yy9meWHvkusaM/KciZp9IFbDuBNVkQVfaeaLmZUFUKkF0xOak1HnZey
         suIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Z/ReGytP";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 13sor66211551pfi.28.2019.08.05.15.20.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 15:20:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Z/ReGytP";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=G0gFHWZTLbSduXOaMLchOdcBu5BZUnGvKngNJx2WzYs=;
        b=Z/ReGytPgMcBSprofJvaD3uijqrHGmjFXhQ8SVTciXecVSXakggzyHWNRDvFhRgU8T
         u6TPdY2PF5xYLBUpllXrYCHhWm8cHP++rJnHYNiU27wjl0NhOkK2oNas25KcpykV+WAz
         uvhk5+gNSSUsdbDCOQhiRwsFqde85qdUWdJmufamVV2FjeVQ2jd+cD5vTpmD+aQGq3CK
         AI9KsM8UqNDc8gYS8zbZ21eIvYP1MpSPEVe86POj8V8k1lu4grw0oNMFt2s04HsPZQlP
         l5pFJo5UMsb+GrSvmNFzB/AmGb9pxgF2lHamLHqRga4omD5TzOsglDe+56mBWpf9b7em
         uVGw==
X-Google-Smtp-Source: APXvYqw/Thz7xsbrkutCxM/PWuqVA1ryJfAAEe/B9LCqZStSRD/vIlf4fE6PvGQNZlDnGviC1E/eIQ==
X-Received: by 2002:aa7:8189:: with SMTP id g9mr238227pfi.143.1565043621658;
        Mon, 05 Aug 2019 15:20:21 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 185sm85744057pfd.125.2019.08.05.15.20.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 15:20:20 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 0/3] mm/: 3 more put_user_page() conversions
Date: Mon,  5 Aug 2019 15:20:16 -0700
Message-Id: <20190805222019.28592-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

Here are a few more mm/ files that I wasn't ready to send with the
larger 34-patch set.

John Hubbard (3):
  mm/mlock.c: convert put_page() to put_user_page*()
  mm/mempolicy.c: convert put_page() to put_user_page*()
  mm/ksm: convert put_page() to put_user_page*()

 mm/ksm.c       | 14 +++++++-------
 mm/mempolicy.c |  2 +-
 mm/mlock.c     |  6 +++---
 3 files changed, 11 insertions(+), 11 deletions(-)

-- 
2.22.0

