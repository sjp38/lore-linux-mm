Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9CE4C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EA7C20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GnFpJ4/O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EA7C20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9DA46B0003; Mon,  1 Jul 2019 02:20:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B279A8E0003; Mon,  1 Jul 2019 02:20:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EFFB8E0002; Mon,  1 Jul 2019 02:20:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f207.google.com (mail-pf1-f207.google.com [209.85.210.207])
	by kanga.kvack.org (Postfix) with ESMTP id 657E86B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:30 -0400 (EDT)
Received: by mail-pf1-f207.google.com with SMTP id q14so8225617pff.8
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=6xqIf0xVqrmwyuBYUV8qbkcY4fEJxDo5YYvPGQNv0Dg=;
        b=Gar49PQDUO0gikx6/lhw669p8rbpqTaC2CsTxTSSs1tTMpPbqKZBE9L65KnX4ONWPa
         XGdFjG/QYQEyLkx1+maDK8l61P8t9CCYKGYI4YWHDZUqXXgzu9NX2wJQk7MzcNhFJAL1
         pCbYwO/u7Sf+lUMzfs5CNf/a6ZQjke6n6AvD5oS8xp2IFU8+ivIWhbw3M1sPgRfQ4sCf
         ammppRaCEIprc+EMQIMzDYuQsDuFUeW2AgqsZFa3C6A/k0RtbP5I0J3FecX4Zu2L4GlC
         BzLtrV/KJD6kjEIRPMluYzYxSpR6iEb1+dkV26tQEr46IBYNs6IEJbDFc7dGfVNqNUXv
         RYQQ==
X-Gm-Message-State: APjAAAVZ3wdso5xEu3k803+An0KPBxx+Y97j/+Fc0UF3U3QJ55c1mNXl
	qsIx7Zoijsiqa0ANrSgTyrkZkKz7L1Tcokx6d3j0r+MxVJKHLT4TMhgIBAlr7SaXOk76515hbVP
	HDhDK/XsfbYWK622tTk1RVQIVvkTIGI0nxxtCrqXqvLY85Kdn9eIxfAd4xX4GzLw=
X-Received: by 2002:a63:f953:: with SMTP id q19mr22985009pgk.367.1561962029815;
        Sun, 30 Jun 2019 23:20:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1CUCxB7gIn9PVMvtEBOgyZMUGKjeWXbl216aFq7p7HuGkiSjae68JPMlNQC+Ds7eqFh3r
X-Received: by 2002:a63:f953:: with SMTP id q19mr22984943pgk.367.1561962028737;
        Sun, 30 Jun 2019 23:20:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962028; cv=none;
        d=google.com; s=arc-20160816;
        b=dAEOftJumTvIQF5L0z35dTqfhlITvPGRm7ndwQlZVGUXCly0HZJ5rf/e6TVY6vzL8n
         /tEQiQkg5STvSuggrcvNJvxxfbSY3dliGGsFSh5wN1HiRgQZ4ULc7+9sSFo8/03OE8Mx
         N7N3QvjMWMrZSNIaSjS96F2To51PXrr4z94yCpbM8t18TdoAEHVuxFBFUxBhv0IO1As5
         XhDpdHW/gYwokoba1WNh7PXgRAGyFR+ir2xC1a21BY4inxHG5RH4cYcbKUbZp40Sx0H7
         +kgJuxvlk+wiFEWhJ155oVfb+ggussZmBCdrEtEO+pa26HhbYWMvNyvYDkhdUV6dCJd8
         vE5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=6xqIf0xVqrmwyuBYUV8qbkcY4fEJxDo5YYvPGQNv0Dg=;
        b=UBQEkEg70ZAxNwYvX7uK7nYAE2llCi/ishnwlAT9r0IJpM6B+QNviMM1bxkE0LjsEP
         K2jW/aXOnyD+uRwwRHiOrt25sGI5VSbVu4ByVmNPaCeyYkGIGkpNpQKbX492ZDM4nTo9
         nhVspMqDCBGjA5qfYAS8X2rqf1fq379KJAIeLhokLpD4k9zZtlDDQqTeOt5AqMQvTioh
         LTdplF6jarvsZXI78WqxDVY4H0ay5wowYSkG2L6S0LS/v36YcFUliIuyu9h/5azi/1mJ
         R0hHOL6+PtxWZ4r7MMLjjqFST1Bo8RA8lzs0StGMdlaEf20IZUppofDa0CQAtMfKOWmK
         TNCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="GnFpJ4/O";
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l70si9316495pge.446.2019.06.30.23.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="GnFpJ4/O";
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6xqIf0xVqrmwyuBYUV8qbkcY4fEJxDo5YYvPGQNv0Dg=; b=GnFpJ4/Oc/100n/wlMN0yyuTT
	qBVa3bbru2+kI55sKA82ZcwWbugtiuZLwkxnhpe5470h26XmfvTn4dShhCGDC99YkHXONgWcU6z0S
	5t/erBmlFFzhqv1WZ+ZnfPaiEb7cET33XrkX7TjbDP0GDKX4lTAs35mFDMwJwFFJXsTbjCCnz9Qsb
	T3LnzxrWgwM+9wArnuvCnRPC5yeDP07v4E+ncJnB+zriXMvtCe7R2MCuImkRo0lDXVWrImhTs8/Hp
	vF2SD1TvWGF7X/3d5CVihaeKKlUv9boEcAw2xU/YcQWyjar7krBJ5gs3T6qNDPoM5TghNpS8HWW4h
	KPFEdN94g==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpfq-0002sH-DB; Mon, 01 Jul 2019 06:20:22 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: dev_pagemap related cleanups v4
Date: Mon,  1 Jul 2019 08:19:58 +0200
Message-Id: <20190701062020.19239-1-hch@lst.de>
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

Hi Dan, Jérôme and Jason,

below is a series that cleans up the dev_pagemap interface so that
it is more easily usable, which removes the need to wrap it in hmm
and thus allowing to kill a lot of code

Note: this series is on top of Linux 5.2-rc6 and has some minor
conflicts with the hmm tree that are easy to resolve.

Diffstat summary:

 34 files changed, 379 insertions(+), 1016 deletions(-)

Git tree:

    git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.4

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.4


Changes since v3:
 - pull in "mm/swap: Fix release_pages() when releasing devmap pages" and
   rebase the other patches on top of that
 - fold the hmm_devmem_add_resource into the DEVICE_PUBLIC memory removal
   patch
 - remove _vm_normal_page as it isn't needed without DEVICE_PUBLIC memory
 - pick up various ACKs

Changes since v2:
 - fix nvdimm kunit build
 - add a new memory type for device dax
 - fix a few issues in intermediate patches that didn't show up in the end
   result
 - incorporate feedback from Michal Hocko, including killing of
   the DEVICE_PUBLIC memory type entirely

Changes since v1:
 - rebase
 - also switch p2pdma to the internal refcount
 - add type checking for pgmap->type
 - rename the migrate method to migrate_to_ram
 - cleanup the altmap_valid flag
 - various tidbits from the reviews

