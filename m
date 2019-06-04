Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 693AFC28D17
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F2A724DB4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WA4XuLy/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F2A724DB4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B49936B000C; Tue,  4 Jun 2019 02:55:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB506B000D; Tue,  4 Jun 2019 02:55:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E9B26B0010; Tue,  4 Jun 2019 02:55:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6543A6B000C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:55:14 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s12so11691713plr.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:55:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=bxnoQG0ijuRDsL2dBIq1SQiaI/rZFtwyO7A8d4rEqxc=;
        b=ZBm60wuqbjBrnWByoYDmB2TwX1fOnaV7Bs5i7WYskyvMhO1VctY+aiqcq1nGQf7QLV
         9/UdbrKwVR54zIo7jB/46edhm78LcE0uAX1x59X5mjTih5UIXbK5Veb5bmngP5X7AFKZ
         ADgD3SaNCz9JEnhlJmhqbtPKm+FV3g7PbQNm0aLNsTwvuTFnECCO9NTUdBAv4BEV3P3N
         i7yWUMhPuuRQk+NO+deFMP+zrMJjCCve+AUtUl0UIIiHI++S/xRXJgp2yfFfqrKEigKY
         M8eIVpsZ/Apft0OGnCggfkgMF5HT/33plNBJ5E9Ay8Z0E4QDUDl8Vwj9y4c2zSrhI45c
         HRCQ==
X-Gm-Message-State: APjAAAX49XqjxNpVlOU7XcZaaqoxyqaTRlHsgDytfHMt7k5FFj7SR7Wn
	cx6e6JEleAuewfwyqpBbE5FVjPrdhvjyNRf4eByxUO9FFJ0KDDmpn9X9tMPSWkrf333hGy5jDb8
	unefAsh3/smkHjrdw+h7fmK9MM2gS/79hLGvPGcyj8D9BJeuNKibMeKXYXqTKlP8=
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr20240788pjn.136.1559631313953;
        Mon, 03 Jun 2019 23:55:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz44/IIOIxTo5E6Eb2LP99/+qsgj8pYCUZalA0fk/bdnQK5Sn3FyPfF7hN7U2bNFY+S975a
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr20240761pjn.136.1559631313075;
        Mon, 03 Jun 2019 23:55:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631313; cv=none;
        d=google.com; s=arc-20160816;
        b=fhIqU6RQax5VQ0GhSagnqymHmG2Zn3PA6YifBOXhTJMWCXjGJvPbiQx+UK4zVrUYEi
         wupjrrcrE49Fwq4+jevFDa9CjizID6WSKRKZfFSU5qn2o3FI1jAuIK2p3F7fcQDNBIVn
         GR7pW5VC/Mcjjz31RZtY/Vpa1VM99o3h2q1aUkx4BfA6EjS/fitfX4GfumsSI9wOFOUK
         XzkJc9OEtWnCDBIf24s6w+5X1JEDzWNumS2u0+nccwF2sVUNWKKruzG2g96veFrXRzT2
         xQ8Ezd+TJgp2T7aXGmQ3snhsdB5+dyrJbt59onHqIXZ+k4bm+TqkJx8OKF8nCM/cdIK+
         r1kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=bxnoQG0ijuRDsL2dBIq1SQiaI/rZFtwyO7A8d4rEqxc=;
        b=mXuorkBx11ug3bDnSCoo9F7Wdtv1rDXKaX2MxPOckW3/G3hjdHM1Fa8+RP183G4sQG
         9GdIkO9iRghF+GaNVdOauVAR53EjGLDjpYvO2a8agsCiP/AoqPOJMw2OCcMSJJenazuY
         nWPuvYomMgrsWiez0Ko5584AELzaogpwfTpQXfcdoVhxGL0ak23O6KW+cSpPLLrif9mp
         nxAjfhS+fxBDAysbPGGmczarcE8DOgSN719+qPg6RirJ3u5/lcXaHoYv5CFgLEIjfU2K
         8alVRAu0nJIq/dkXvV0I1RISs5aR7qUmHx6Y06pN6GUMsBwxo0XrRmduNOjNtVNiMIlP
         M49w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="WA4XuLy/";
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s138si16703378pfc.148.2019.06.03.23.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 23:55:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="WA4XuLy/";
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bxnoQG0ijuRDsL2dBIq1SQiaI/rZFtwyO7A8d4rEqxc=; b=WA4XuLy/pL0N5n09h+1lolxMj
	TUAhYXwjnwJJZyUxgnxzMPFg9I0NuRJAZAKLgr8jViYrmseCTyQIfNxRTLIKFw4zzxV1qG3bFI3ik
	DtsIfrbtE7c3vD+/ooSOMNk6jgC17JuriYfaysroA4hLy/C3aJcWBamfH7RoGUNBQ1q9h91jrDgdX
	PKRZbvnnXTz4XSlxMFrkwsa9ngEKk8wh/vlIqQkA5chsCkL4HSSkUT0MuLM93NQ+JZ0DMq85h1gIe
	X1WIoNFTb6iFitzENGlzBXr2XXuRr0BW+XL3sUIyA0+D2oRQNHSU5ZeGwH38Y0Xwg0ViQd3Z2upBt
	JimL+peNg==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY3Lf-0002ih-2y; Tue, 04 Jun 2019 06:55:07 +0000
From: Christoph Hellwig <hch@lst.de>
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-xtensa@linux-xtensa.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: cleanup vmap usage in the dma-mapping layer
Date: Tue,  4 Jun 2019 08:55:01 +0200
Message-Id: <20190604065504.25662-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

the common DMA remapping code uses the vmalloc/vmap code to create
page table entries for DMA mappings.  This series lifts the currently
arm specific VM_* flag for that into common code, and also exposes
it to userspace in procfs to better understand the mappings, and cleans
up a couple helpers in this area.

