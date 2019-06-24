Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97475C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40EBF2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WnxrlYY9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40EBF2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A49C36B0003; Mon, 24 Jun 2019 01:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FA718E0002; Mon, 24 Jun 2019 01:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C22F8E0001; Mon, 24 Jun 2019 01:43:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 597846B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:23 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so8888773pfn.3
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=G+0O3j+cgCRbigr/X4MIfnZa4yWmCGHY98UjePy9hlI=;
        b=G3wgpXvoZJQ2ow+IaMbB714v25jUUMJ5A5up4yESibI6QzKsxwDTHzP1I5UGDBksp4
         jhCGMb6nYn0braAK/IOVm311G4wCxYdZDR4BV0ylQxp2NoW9DTpwv5bkF1+g0LTibTPM
         uVP8GxKScjpeKRc5O/VXVVLpEFd+7cmMNjdoK4J/iZtG9+Yb32sRs4vWxNu7gK4NADWG
         d59OU1/ArlIxnKJwFckrWwg6zS4UHWgCrvaxarqm23yC+g3mZThE50i26LZN6N5PqihW
         fi+2VlmZSguWokQBwpPTTsnPO1Y5Wd9cTmfM5Esdk+5nP8wpVrmd8LzCoe1vtzVy+7ZF
         McMg==
X-Gm-Message-State: APjAAAXjFnkgddrhjCynUbdo42fL+ZedjKohQ4I8CIhoGzRQoK0UvTrn
	kFUrPvtvQfDkmOAGhGXrJBqa2Nx88yD3mudzVSYE47PlrIJGtm1T0nPeqPMokgTcES1mK2xF+Ng
	GPUgkIzsWy2YAyW+HvdXgEMiSWPIZWeMJBcA2DBLcGUprSCQLg8exiPKCJufTSP0=
X-Received: by 2002:a17:90a:aa0a:: with SMTP id k10mr23192742pjq.43.1561355002938;
        Sun, 23 Jun 2019 22:43:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwml9+H6MvO6Mgarf6ZfHYfV9CyX1ep3evP3oEJn61cDkwPMwE70nxYi3xpCfVvuf3LEJNE
X-Received: by 2002:a17:90a:aa0a:: with SMTP id k10mr23192686pjq.43.1561355002117;
        Sun, 23 Jun 2019 22:43:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355002; cv=none;
        d=google.com; s=arc-20160816;
        b=ZkXGyl8rQ9H5nNAKp/wL3QT5Xo0MZMGXipj9vMb9NrXdx6GffGWWYRY+6cWLYSP2Vf
         lZuVGlHusCy3GRDirUwnpKn2db+uB4bUBGoQw7uNU311TKVvA8jzJPs2hTM84BGfE20i
         2+zlPYX8nHGi+SrJfu+Y51GanhyvVNaKv2mcNFjGkMgPbVBYo9ZrcfCXIC5kG7z3LCv0
         AzsWlAktMX6gVGFWQONAt8NS/1o9yaRMXZxZJK9tFCWGbWAr6GL8AP+/AdC7wtBLvIbS
         cG4MZL1hQy6AqBRC6+zzQVQ36lYIzywYy4hf3w66M4pJYBMZisAxWYYD05SoqDpGMbeM
         c5Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=G+0O3j+cgCRbigr/X4MIfnZa4yWmCGHY98UjePy9hlI=;
        b=mlcSPmxuks5QpB7sa+BM80zkg9GsN/5/k9zswCnx8634jewy3kBa2BiXT8RE0nPIE9
         Z+4BAZUpr6kvwoTAttiRUAgK2jcPhcfUK+LQN64jecKG0xlwC2CSaiATDDpm5EsxHWZf
         HkhCS1KQGF1vFuQiOIMhOZVE2KT9K/Zb4CTvXZ6zI1dsXWcb766Ja27xhpjN9Y3DYHsA
         Y9rfxoM83mxJIfFezttpavrAsqlwFRGeWAxfxZv0krHRk/4YbR7VF/ZUvoOWm8qSyrQz
         SQEyt+me60BUw591iEQshbgXxh8phz8zbBm2l933Q+gaXn6h8QxkCpuir0v2L8HIqgxP
         l05A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WnxrlYY9;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h8si4564822plt.16.2019.06.23.22.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WnxrlYY9;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=G+0O3j+cgCRbigr/X4MIfnZa4yWmCGHY98UjePy9hlI=; b=WnxrlYY91HMHTqus7NTc7TkvF
	mDPWku21XSxCKeAPWG/rATrzM+mOEukkUC/aepN9oWr4+USpYvA6rpAheJljOmRzQv4Fosq0IXzQ5
	/lR09sihl/AgaGkaKRV8KZ8qt+O/HskRSKeBwYzk/8zosnQmWPGzXDAlZlrhivb2Ac9As7JAEwRNJ
	azOD6kksRz/fZE0Xp3xOqBk9GkUgfdaz3LB3v81wBIAkvvg+0PxRQ7uMYCsFgPJv5SXT1g+IOC/KD
	cbyUJ+5yxKazc4N530ff+eGFiHIO6qnd842pID0hlRpAQzqQiX+fvlTTJg6I++Na6SvSjjsEUibBz
	zXKRYKCwQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHl5-00063u-7r; Mon, 24 Jun 2019 05:43:15 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: RISC-V nommu support v2
Date: Mon, 24 Jun 2019 07:42:54 +0200
Message-Id: <20190624054311.30256-1-hch@lst.de>
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

below is a series to support nommu mode on RISC-V.  For now this series
just works under qemu with the qemu-virt platform, but Damien has also
been able to get kernel based on this tree with additional driver hacks
to work on the Kendryte KD210, but that will take a while to cleanup
an upstream.

To be useful this series also require the RISC-V binfmt_flat support,
which I've sent out separately.

A branch that includes this series and the binfmt_flat support is
available here:

    git://git.infradead.org/users/hch/riscv.git riscv-nommu.2

Gitweb:

    http://git.infradead.org/users/hch/riscv.git/shortlog/refs/heads/riscv-nommu.2

I've also pushed out a builtroot branch that can build a RISC-V nommu
root filesystem here:

   git://git.infradead.org/users/hch/buildroot.git riscv-nommu.2

Gitweb:

   http://git.infradead.org/users/hch/buildroot.git/shortlog/refs/heads/riscv-nommu.2

Changes since v1:
 - fixes so that a kernel with this series still work on builds with an
   IOMMU
 - small clint cleanups
 - the binfmt_flat base and buildroot now don't put arguments on the stack

