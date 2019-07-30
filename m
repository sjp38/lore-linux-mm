Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49F56C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B58120679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TcyrmqgS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B58120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA0B8E0005; Tue, 30 Jul 2019 01:52:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5BA38E0002; Tue, 30 Jul 2019 01:52:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94AAA8E0005; Tue, 30 Jul 2019 01:52:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4058E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u21so40095969pfn.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=a6luPAARjEvL6+wrepaiTAj3y4NIety29NPDFmox12Y=;
        b=FKpMZEQE8bDXEh0juY/X4Eh4QdKsjyQxVKxp8FuYRGTBq0qN+HWt9HTefU9ToXjyBy
         wLGbFxjywcbWV5/F2V23kj0I1/BXOpOmHfYynh+y6Q0RxsmvYPH5VKxvKhrbjqcfkVpO
         ybVYXxIHTJpMNlQg9Ybf6UvEWXaNabQrPMn4LDjMKxciapKV/w2f+P28hLJK25+rJgL+
         mfVfvBesGzd1udnJM5/6hpno4Ua3hRli0KJGfMbfD6ZswZhPE2pD+sXcS+SBDHKbxFmk
         3bd/yq69CTK6G2UKxsd+sy9F1Ct4ZluelJjvz48y+iWOoh5VjwVYlk5y5+6T2lWzJHME
         EaYg==
X-Gm-Message-State: APjAAAWhQgS8teRe9ACfCUXZ4DeYuQWsahDN5/uWxta+VzgywGpCgdkn
	VCKZojWBy5rzan6cWBDYfwIrF+PWIBy5tslIkGlQHgbLZdijUVi6lgopjnyXNfdOGjqBDlsHO9E
	OfxwrlUVxFHXOyiMf1LaEpPHKbJK8eKr50o8RD0c+lMv1Vf/au2z0G02xHxajf70=
X-Received: by 2002:a17:902:7687:: with SMTP id m7mr60094373pll.310.1564465940026;
        Mon, 29 Jul 2019 22:52:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1jf89FZ99hlsLyrv8iy0og10iA7JbwVt/gPATv4/E6ejgwbAs2OpcxEZXWV4TqVgnH9y2
X-Received: by 2002:a17:902:7687:: with SMTP id m7mr60094344pll.310.1564465939338;
        Mon, 29 Jul 2019 22:52:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465939; cv=none;
        d=google.com; s=arc-20160816;
        b=CGN2+v7ZuCGWNzrPU1EcMQgMQVACwKHueE1W4nHDS2Yqe6htacZ8jkhXIYjSjW/USs
         6Ihk4cnYKnzoV7RswkQ4HH/Ey9m8avCjtic4m01TSqff8zCJ11B5JSNlHJq1PeUfOuBu
         SgQh6vFvghgt12C8iTG+x2z50Ys85aBNXd1AjVOUKWulTBDlErL6K30gs7KSYmJ4ZF+s
         qDEbJem/qkOBm8DPiUyBvhBe21+hbhkCVf8ZnX7kVufvkjXUMTqkdHMgIENn4m+VaoKY
         M7edTG234RTxnCm0W8rWwy9DKZ2VrygS7VlYLQdCg5uA3tDLPnMyye8csOfEitw4pPy4
         i16w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=a6luPAARjEvL6+wrepaiTAj3y4NIety29NPDFmox12Y=;
        b=1It2ZcEYDwoF9oO9A9weykXWm1lfDAH3brhTvqVPNAkOWX/vNED80HS7KAC+zPaZHX
         2aaAD0+tp5e5zHR3E66D3pjixBqdJu+uIuMAcUZ0/OvjJIwpKQYMsZwI5YV0yBrL8IeX
         MhwPKR14Nz7S02dBFSW6KHa5XsHUwxL4NIw4axfxB6YKfa4mMahoTQ9186gTYoky9GO3
         nms7yTfKbKB4kT/gTBKslfA2+rpZjJzXu+LhTW1QuaObUhlwOTvQDzZ+h5yzbsscfYsT
         HnpLusGMePMqWGD+4Vtc2bKr5ogvjdfXcqnK2jtB1w0dW6guVOjvzPyb68ymdpvsLsky
         7X2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TcyrmqgS;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q32si25610042pjc.2.2019.07.29.22.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TcyrmqgS;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=a6luPAARjEvL6+wrepaiTAj3y4NIety29NPDFmox12Y=; b=TcyrmqgStzKv1ExUPq4X25C2K
	GsS0yBUn84eEzTV3G+bIV6w/Wz+zdOtTQgYRWctpWBG4m8RZX8Wy5MsS4r7N3hmMjWfF6ufk06OEH
	Lb7wBYPu04YPbG9Q8/2AJ6Yg8EEmECICcfu4PZLtOkUbiZWv74mKnfRaChmb+dINOOXncvrUhYWIv
	FKLVC7qSEfWk3r47f87nsmoAX+/yb/XktofWaUBfRO6uAoKsabsXIxOdJ5S8pbSz8XGvfre96fE80
	m2Gz/7orow4ek0yS3DFI6va1nnSu5TOByhwgh6aRhwa3qUsmh/YCoO7ECAkPuk19GkYAT1cbpKh6f
	QmbBIraeQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3W-00014y-Mf; Tue, 30 Jul 2019 05:52:15 +0000
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
Subject: hmm_range_fault related fixes and legacy API removal v3
Date: Tue, 30 Jul 2019 08:51:50 +0300
Message-Id: <20190730055203.28467-1-hch@lst.de>
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


Hi Jérôme, Ben, Felxi and Jason,

below is a series against the hmm tree which cleans up various minor
bits and allows HMM_MIRROR to be built on all architectures.

Diffstat:

    7 files changed, 81 insertions(+), 171 deletions(-)

A git tree is also available at:

    git://git.infradead.org/users/hch/misc.git hmm-cleanups

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-cleanups

