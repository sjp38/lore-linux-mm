Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70675C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 225AA20656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="f0F8mUp3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 225AA20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89526B0007; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2E468E0003; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91E178E0002; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46F166B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e6so6857271wrv.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rs1sEkzygtR6lbRJ0eUbAFkZlHYnT1CPNgA7awG9NQc=;
        b=D4BvSBgYpS5IxpPNmX0vv1uWrHU4rNZ+drk95kMvUKqB2zsmMS48OCZbP3bFjL+MUl
         ywbDZ0RwoxFhiStiI0/R5mWKyEBW2ZkyWMU1NOusNM0C7LXj27pCuC1sugUyxc1LuEZy
         QPgYT5NO1kx3meTe6CavYnlek661EK+AIqqePCwYMeysYvGdkRk/qpzXYdbrD+Ax25Kp
         pTE81M3lVeXu45lO/TCgqF6z1e/vFgQkgzulNWz5OFY6OtOkUTh6FOG87tzshpmEhHlR
         j5CFD9C5mYP0v+yShJOhYnm+F7mrSpZ5KVpt8+MExsgZ+egDm8QLHlyFJZpbmq/SAhs3
         PWSA==
X-Gm-Message-State: APjAAAWC/fXJfolWipoW9TLsvdGSqeqYBSiGXT6cs4RJr8bGZQ4mmeeQ
	IkcXqOvklYnvZ1G9Na75VJaaYfjUaxCgTvhmRuUUqkfmzWlPQL5SgIaTcyQ4H0qZlSVMDf+shqr
	SxphnELMf5MhYlrXW11g0yvVHwOBjEmPqXplyzKKP41PTUvRrcuZ33FhAECcakGtdnQ==
X-Received: by 2002:a5d:4302:: with SMTP id h2mr15490214wrq.137.1561410124612;
        Mon, 24 Jun 2019 14:02:04 -0700 (PDT)
X-Received: by 2002:a5d:4302:: with SMTP id h2mr15490190wrq.137.1561410123789;
        Mon, 24 Jun 2019 14:02:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410123; cv=none;
        d=google.com; s=arc-20160816;
        b=PaUMIEuU4X0FRh7dyJalFqecQrJgo8mvhM3XUtAIJV4b6MYxlOxsU1RxxYDepGtYM+
         X0XDiGLzV43KUtEfzypIIzejqK4Y56nU9YYY4ofVSDgFl4FvnByOCTIGkyed/LioJV2J
         O0vq0/myYqHlqaQXdmxx+Y/bYHRxYfTduXHmnTLzMrtc0ba3DcnRzIIgRLvO5IA0v8GR
         dOZbShGQDPoosoHmeaBo3QUwupjqRBm/ecd3+FHOWpkvXsvrY+AgIoEtSw3yPmWcLcp1
         Hrn1NBRfbJQAk9frfmUm43T/MGTD/BVj502CPCy+VHL1hxSMLi7sTTtat4AiufROsU3m
         32VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rs1sEkzygtR6lbRJ0eUbAFkZlHYnT1CPNgA7awG9NQc=;
        b=TaY3kQ29TEDZmgNG6GU748XaPWzFbhERT+l132UBwtMdHUndXe4sGfvwEyInbAJwwS
         i4LTrjog1tyckYYrKA6d4mkXPjVUsVH6Rvro+U80nXwZLveGq9kZkaZdRqkl4worOKNb
         8SSFeSZKlCMfSxBWWPKTs8WDUJkRqYr/gGYTrDtfry6kapXQyH5qgpiwZBBIuXZ0wZVD
         cPGQJqOjAIOv8uQUF6JyGdz6rk8TJP51ajkQt1ZUITQDygdRN1alpsBfqo2vF+cD9JVE
         UTWjN39IR47kAL0+T8tQMhI5Pwq3pR25mDuDd1bblDJJRrIcS1l6oCIxl0DITlHJHz1c
         Q+gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=f0F8mUp3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor7223427wrq.21.2019.06.24.14.02.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=f0F8mUp3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rs1sEkzygtR6lbRJ0eUbAFkZlHYnT1CPNgA7awG9NQc=;
        b=f0F8mUp38+BSw/O1WjANVXVVMw8zhFZORjdRX1RtgtwdBgUWBtS4DuFgknhtRckqjJ
         fDPYac3PHVynkBRdhou+SH6UptVQIxVUIQifavRFZYv+BeWfES7diE3vVczt6RfpUEOL
         HKyKRdDLLYkWyPF33zlBvSCxa/KBn2/+Y2Sy1hmyEQzxoSkWZdP4GxRWfGqLBUquGL9C
         Ly8tJeOzyL9mpaDnKGNVFtycDXcnewWGVJEzIZFjBXuryCCVlKkVubMEGUB9qDKesfui
         S5zt2wnmoNX0dsm2two3hmXge0XbsLY2LY0GsVP/TYD0CD+hqf8x5J0pMRR0Lz+jvG54
         bukQ==
X-Google-Smtp-Source: APXvYqxoDaUcVHfte6JF2hIkD4U/Q2PNoEzAwuS3zYv3vRjkVzwDyM9fIRPi2AhLNMqFWzhsn/OFnQ==
X-Received: by 2002:a5d:5446:: with SMTP id w6mr102260622wrv.164.1561410123399;
        Mon, 24 Jun 2019 14:02:03 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id h14sm11086221wrs.66.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6D-0001Mp-1k; Mon, 24 Jun 2019 18:02:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v4 hmm 09/12] mm/hmm: Remove racy protection against double-unregistration
Date: Mon, 24 Jun 2019 18:01:07 -0300
Message-Id: <20190624210110.5098-10-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

No other register/unregister kernel API attempts to provide this kind of
protection as it is inherently racy, so just drop it.

Callers should provide their own protection, and it appears nouveau
already does.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v3
- Drop poison, looks like there are no new patches that will use this
  wrong (Christoph)
---
 mm/hmm.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6f5dc6d568feb1..2ef14b2b5505f6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -276,17 +276,11 @@ EXPORT_SYMBOL(hmm_mirror_register);
  */
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
-	struct hmm *hmm = READ_ONCE(mirror->hmm);
-
-	if (hmm == NULL)
-		return;
+	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
-	/* To protect us against double unregister ... */
-	mirror->hmm = NULL;
 	up_write(&hmm->mirrors_sem);
-
 	hmm_put(hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
-- 
2.22.0

