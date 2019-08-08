Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8F85C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 457462173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QTY7+sCw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 457462173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 998846B000A; Thu,  8 Aug 2019 11:33:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9487D6B000C; Thu,  8 Aug 2019 11:33:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 837356B000D; Thu,  8 Aug 2019 11:33:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C60A6B000A
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:33:56 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g18so55677678plj.19
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:33:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=fPGllWDdh64nUfOs1aS3QjslyfGjQ/iJx/2zlaF/SN4=;
        b=l5JNCMqdx3mE0ldDdwgwxRh19cIL7eDJWJfPk88DD6IJAndMpTevRBILHHAweYfWnu
         PAQ7fWcO05f1zRqZWahucwKweqsv+nA/jj42ahEp9o88UCLSub2j+Pj6MtW3Repn6tY3
         0+bx0XMiT6oqp3MBjdwNHsAjiUZz6AFq34F1zWAYCbV77z/8iEB427Q2SIzr7OUacyN3
         5zj2pWFnB5lDRomMf5zNGEBTvT3DJFFqMo6wgm1unujwysAsbtPgwgENz3AOVeJaoU2W
         eirDVnWAdb8IPbKApw4kkpJF5mPTs2ehYrPL2Xeem3jdo3qNt5QvRV2ygkHFkC3ZHQXU
         9Kzg==
X-Gm-Message-State: APjAAAXjDFvkDjyMrBpj3Nh6hTei0lKghM0QwzDt7oQtEEDdhf+eBbTL
	JUG1X84r2Kpgh7aAgQX9I+HN2xQ03HG6nO+cT8xDImC3X32S1yqx6gXze/2SeOPcOlA/Dn2SpJE
	05xFdN4xdWhqPqLQ1CNKjGJo84edbHW38mdc1KBF4nNoc9kwJxfp6/vhRxOjexZk=
X-Received: by 2002:a65:6846:: with SMTP id q6mr13401788pgt.150.1565278435863;
        Thu, 08 Aug 2019 08:33:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKlGR9W+HtTgPXcxVoLwhAauHYGvsogBNdAHOMpDV3WbuCTvtQD90gdOEEDtRi9Mn4v885
X-Received: by 2002:a65:6846:: with SMTP id q6mr13401706pgt.150.1565278434909;
        Thu, 08 Aug 2019 08:33:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278434; cv=none;
        d=google.com; s=arc-20160816;
        b=EJcU3iLJJTdTDqoMVAg/WA1ZOmd89Y3wd3dNorD6xbVcT1zIQd7y8HdlVDsOAsUOCE
         1H3gMWREdCI0O98vTlHtLhkTU5e4lYkbI9k7teRHolBPWP3b+nJzlEqh2o84cUTP9ils
         tU36RprPTscQOKazWzpaI310gwD/JFhCKQnx+fz28SHbm5lxOk3hdiAAMo/jSoIKfuEs
         aBdarhWTgk/hAiy71h9ocnt3UOqUkEGTF9PzSTsNUegPfSFVIdcnR1TCjxmkF2W8MMFw
         3mW279IkHyTQ0BbCDh5Pnq91SafClfTunAIfgKcdrtdxzTj99ITEg5v9QCm4P0k6WxlB
         S5Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=fPGllWDdh64nUfOs1aS3QjslyfGjQ/iJx/2zlaF/SN4=;
        b=SE6exVmJZ/nP0xa9zgrf5HjnNElsOSXy/zDPCM5fws9ldKU+C2ffCzjdW35MXguxH5
         xr4Mk+S8iIJdb/EfZo6clHL6dbsbmt+LeGbbUDbGc6Gkb076h5Fkmdxhh2SRX/2N1hzh
         CvzR8jLlX8woEAlf9+Gyae3SuwuwXCKY818WTRS9tbh2T8qnc5+V/Os+rmsAmV+3k593
         YXGp8swDOrqTmiHI12tfHeFXOQu2maOEA94gzOYYIlSgZ6wTNTkjb6JcJNBzApofqMGM
         0GlcY3MXAb8DdotNZdLHsnFRxIRFQIUq9uXYZqlSjQttG4ZefDEeCxicVcE/XKnNG74Y
         VQdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QTY7+sCw;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b41si2918934pla.155.2019.08.08.08.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:33:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QTY7+sCw;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=fPGllWDdh64nUfOs1aS3QjslyfGjQ/iJx/2zlaF/SN4=; b=QTY7+sCwU0BZU2WjQGtou3n1/
	RaWyLK5P/qG+bA80TktmQ4ddbXbYiDiqrC1m10wB4vGdGam/nfd3GWLHcEtUEQXnojGvCXInVqA8V
	ee1yHncvrQI8DqawF3fKeaPiDKYLwzb2rlkHGIWG2Xs56d6OFpVCrJmUTCDG0SVuabWVuZ5lSYg0f
	FDjUOR1WkYhep9qQgHGvKkYDcsTUS7X/VrMUXEneveGR/4KIexnaGhqwBecUTIRGg6gBkvx0TIs/F
	7njM+Q1mXMwVT7z3jzQrcMNuZ6tshLHJqB3FYBJvinsQcaKKHi+5CfzC9KOjUE4EYU1F4tceKSDHo
	wImVvIJ8g==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkQG-0005A3-GY; Thu, 08 Aug 2019 15:33:48 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: turn hmm migrate_vma upside down v2
Date: Thu,  8 Aug 2019 18:33:37 +0300
Message-Id: <20190808153346.9061-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jérôme, Ben and Jason,

below is a series against the hmm tree which starts revamping the
migrate_vma functionality.  The prime idea is to export three slightly
lower level functions and thus avoid the need for migrate_vma_ops
callbacks.

Diffstat:

    5 files changed, 281 insertions(+), 607 deletions(-)

A git tree is also available at:

    git://git.infradead.org/users/hch/misc.git migrate_vma-cleanup.2

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/migrate_vma-cleanup.2

Changes since v1:
 - fix a few whitespace issues
 - drop the patch to remove MIGRATE_PFN_WRITE for now
 - various spelling fixes
 - clear cpages and npages in migrate_vma_setup
 - fix the nouveau_dmem_fault_copy_one return value
 - minor improvements to some nouveau internal calling conventions

