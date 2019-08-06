Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49D1EC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 071DA20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eIIvEQvb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 071DA20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A28126B0005; Tue,  6 Aug 2019 12:06:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D9676B0006; Tue,  6 Aug 2019 12:06:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A1226B0007; Tue,  6 Aug 2019 12:06:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 562446B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so56193153pfe.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5MxxtDMNs1Lvn21R+Aqvcobycge3qF/vKSqdu5UNw7E=;
        b=Ka4R9uI22+JLwOK2gH94Q5f8D87RaXEkzYhY8mSFcjaykl6rDEguBNnW264A7/qTem
         OCD9XGK521OXA8O7WC1ZGqL6cOY109GihGVMN7Kg1XbgQOpyBdPiM4fZ4BONhiSompy8
         OaFVFXJB+5Tw9H19cByUGdJijOL2CQSOpZUeWLArLFRCbwn4q3i6VzI9RZ08NK3ODSfm
         TQzORvZ6naq9Dkh4R++C4roGOGtHr4rgZRu4S3bqhgxUCITIH28ttSLFTi6GRq5RiC5H
         1tEwUalJeTDd3hscPIaoWGBByoY1GgM+fOfz+TwEthOFJMt6Pw9O9N36EbsV0HThuQi4
         1Arw==
X-Gm-Message-State: APjAAAW92wav4wy2RyM+75ke4OFxEK2103KbWafQ1G2kKb+rNaCH0sAU
	tPu50djZy54wlXdB/S6lG3cOD3H4nHv4+zu+hVDBLjQFuCJ8EF9SAQaNrmtweaWejtXga4ptl1E
	IIv/Nh8sZA9kkVDSc3zrqoIL8firv53rLLdjPXnMfkcq93TolovaiBl16b37NYfA=
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr3922528plt.152.1565107560913;
        Tue, 06 Aug 2019 09:06:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAgXjaSW/LvXEWgDcz3xyAnIN7Up0hc59OFeqezddQbOSBWKSyXgXbsOaIrKHzT84ha6EN
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr3922448plt.152.1565107560154;
        Tue, 06 Aug 2019 09:06:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107560; cv=none;
        d=google.com; s=arc-20160816;
        b=WyiDSXrXCyTQPiwk5GU8GMuXtvcAgDxArJ6hGQERGIGu+NUeL8GU4pe60+sg96S8hi
         Lvygb0pdsPIN/f1MY8xlwTA5IwH4+Sht5ZQ/BMFaykZ3UlJ0sdR1PQfmWEE3XyiMFXZd
         aD9RgrqqR2s8CkKiLIdqkqm7RE4xgUcqJB+NGyXlJ8herftu5iXj8Bbl/j/qWpN+t8kM
         xM2NyfLbJw1lyCjbck21q3QuYpHQMlrqI6+aEz/eTG/uB4jmdMCOg9S8wCzMR7YMxEZg
         nrvsoAALh3G2X2Z4Ux9gN/o4Ps2SRBfF3XJAlbE0ds4P226ZZY+XDbTdaFrAS8BcyucN
         yTgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5MxxtDMNs1Lvn21R+Aqvcobycge3qF/vKSqdu5UNw7E=;
        b=goy8G4UPcCbJKQ58vEIaok1etiwa90/zTDFzUtkQLjI/tSyiKPRqPyhqCUFz3daiy0
         Sgav+nVFJiLmKzNMHySEbAVHuLEgbis1R5HW1oGT3KN0zNzbsmCDWW9voCY/CfUzCUkg
         P7Xk3a+gaJGZ4p/x5cXUxnZf0zuGwbKVOs5RT7nlkT5jDZvFjS7w08BesYzFunbKlJdc
         Goutlm9m7n+n6ZAuUnS8TrqHj3LblbwcN7UX/rOBR28qF4/yKypPqWc57Cc5eBo/vx//
         vOX1iF51Mg59KUZxZQEeyLpC9AiG+Q5JtIWzHg4/DAn5q4hi+p44Melmn2voeERtKbpb
         PyNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eIIvEQvb;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b73si15209941pjc.53.2019.08.06.09.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eIIvEQvb;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5MxxtDMNs1Lvn21R+Aqvcobycge3qF/vKSqdu5UNw7E=; b=eIIvEQvbf6HxKp4vB8rYWilc1
	Y+u02rLmHHgGDQ0BTiNLEYHLedfAofs5F3rHecD7klB5qWZyLsUVZ6dxMkLS2pAWxn04GZTAsbBO/
	ouTJ85EOwF/aluMfxLMuqi+nHzvOBHhK79wk9TKTlzEO/ORS3GGMIcaDAA5aQ/dikzACu9/rM2gl6
	pdRKvVBCY0KTPXd1q47Fs+imhFbAzx721LUs3CqY+31uYX516XCJ473j9veaAi1jB50nfgfna6Gf6
	LLlbHAeFh+Cb66JQz5UcvMUc+Bju9mEnnjbibagKSd8OEOzKmC4fRTXUeOQC3Q/7CRnpMm8MDH+Ro
	R8ayd9OvQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yG-0000Ve-2p; Tue, 06 Aug 2019 16:05:56 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: hmm cleanups, v2
Date: Tue,  6 Aug 2019 19:05:38 +0300
Message-Id: <20190806160554.14046-1-hch@lst.de>
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


Hi Jérôme, Ben, Felix and Jason,

below is a series against the hmm tree which cleans up various minor
bits and allows HMM_MIRROR to be built on all architectures.

Diffstat:

    11 files changed, 94 insertions(+), 210 deletions(-)

A git tree is also available at:

    git://git.infradead.org/users/hch/misc.git hmm-cleanups.2

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-cleanups.2

Changes since v1:
 - fix the cover letter subject
 - improve various patch descriptions
 - use svmm->mm in nouveau_range_fault
 - inverse the hmask field when using it
 - select HMM_MIRROR instead of making it a user visible option

