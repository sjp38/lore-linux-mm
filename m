Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13A17C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBCDB218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZoXDWaM0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBCDB218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F838E0026; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ECD58E0021; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CC998E0026; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D98418E0021
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so2291957pfi.6
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=aR9uGMKGXKbHfq0jNFOgm2SkQaXqyDisE482MLvao/8=;
        b=kPfD6aPgWeR8s5lxutM/e8B8181+sVFldtFRyaZ99f0fClTRUq939xxEBVhwbCkxC7
         wvqrgGk76dZ13L9gj4apLj+ShAB7LgJECN+SH4bw3LkEd7eJtUzXKtpG96DzSaZfhTVA
         kvIehF1k8CJpFZdGiDZ95EK9M1fEaczmZB9qzerR8xsQXp9O6K1oSWGWQC87ciqtSJNi
         3FhCWEltVgAyaUIImQgWDXNEasJE1uI8pCa3jkeNRNKapC9sjGMQH+oaJFm8YNfzve9Y
         xeZZcCtlNjQW4KsR6/BMGXvU+0maBZTNVZNdoo0rp0Up9C87IXRPpap8WiC+/20ahPpT
         bLsg==
X-Gm-Message-State: APjAAAWIazior1O+mt3AthkRXrC29O1R+cLIJ2KAXNE+n8GzbY/JfrZr
	IGHpX7dCNUeaTn2rVWQlBUjaHRO2DZm2Nb+4b+c8S3VfgEdji1gHQFBkAobaYkyjo9EQDaYNMil
	JKkuo/QhJgpLaG5nA99e1ZR1GqzyISRWHJJ+EJMheQA2E03TyT8gUq2bNrqimxRU=
X-Received: by 2002:a17:90a:cb12:: with SMTP id z18mr14667034pjt.82.1562191340429;
        Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiMzM1nOe3CFV9q9RRbXX+RmsKGkLzas06ulwkcGnltGmHJRczX/g6TffV6YbCG7saBw5j
X-Received: by 2002:a17:90a:cb12:: with SMTP id z18mr14666986pjt.82.1562191339647;
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191339; cv=none;
        d=google.com; s=arc-20160816;
        b=LMyVl/Va588OpqJz5QbIO+iljWYosGPP0S70w2spaVgFbxtbeNfhDAQYcKuDcCyrvE
         UFe3rEfaetc0fasHi8Kl/kq3t27SQw2xGy9eDiwWg5kbuX+Crp3UcDJDOrCDYyrfFCSM
         YCBU4VZOnI2QqQUMAm9g9q8TFKjN7TLoM+G8xAFJcyK+QT8Z+6Ti16GVhNUS46vWZY88
         o6XiI9J2s5fxbr6C4Q0u7/95eO/F1wp8BiE4mk4HuW7Y97zyJTGhMas2k4DkOzaQelOk
         inhi0l6uy6/Bbpz2av9JO5bnmV8/oaVGSy0vrUPD+gqPeCAv20/KsknICycTeWku/CVU
         DtjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=aR9uGMKGXKbHfq0jNFOgm2SkQaXqyDisE482MLvao/8=;
        b=gwgI1YRYNrlTw5FWnKvR95BX6JZWnwNhcLuMBCF3T9hslEnmPPLgf4w29ZHkL0b/f2
         ro0/mV7YHBcUlESdoR01FoQOnZdbSh1CMkcUWYRl4S6r2M8U+qlfg/0D91I0HG7gO4F4
         Kwt2K2NKKJanMOZ0b/Ou5ol/uBciqdKnmFnaXiCExmnbPcnSq3bbgN4YYoaSkT1ag/8n
         i/RV2I9K8MnI+HJA7AqbwZ6kRV2njf1vNjpZhNwUouNNJU3oFeFM7aERm5WBJmmMH9LR
         GXvkORrbtB8ZaT+//1W7F+MEamQpOiM20SxJk3PLNxPhXMUgTJj0PtKkGOcSL8NdKOya
         InNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZoXDWaM0;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s12si3424570pfm.113.2019.07.03.15.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZoXDWaM0;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aR9uGMKGXKbHfq0jNFOgm2SkQaXqyDisE482MLvao/8=; b=ZoXDWaM0JtTHhc2otW2p82e/T
	/jNnbQZZmVgh2h79y9++LJbnLByPF/oaDm7Qo7iKHdL2D4Ih95NUhDkWF3aTF78fDdiRt4AArcezL
	HbG1KY2whzTjugStJ0zV9TMW005Tf85+ZyT8SLxtOeO5JSTgxOIzL8b7Sx0xaCtGUxic8y+uI4Moj
	bpjSCQsQetvIZf757cl9CAMduvgTlsWQBWKzRSxxwPAOi7TNaZ1BZD6oqtaqqwD1QdwQl/X9DJJhn
	TRzWUblKWO70fd5ENlz40DeZ3x7FAWOeqQradP3mRmuFpOzbg63IOXzNu4J8MfzJzyqrXb1PfSjVV
	oappvp1fQ==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKR-0004EN-KS; Wed, 03 Jul 2019 22:02:15 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: hmm_range_fault related fixes and legacy API removal v2
Date: Wed,  3 Jul 2019 15:02:08 -0700
Message-Id: <20190703220214.28319-1-hch@lst.de>
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

below is a series against the hmm tree which fixes up the mmap_sem
locking in nouveau and while at it also removes leftover legacy HMM APIs
only used by nouveau.

Changes since v1:
 - don't return the valid state from hmm_range_unregister
 - additional nouveau cleanups

