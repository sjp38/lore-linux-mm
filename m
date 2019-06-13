Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 537A4C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1770A2173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LoCmgBKL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1770A2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A37196B0003; Thu, 13 Jun 2019 05:43:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E69C6B0005; Thu, 13 Jun 2019 05:43:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AF286B0006; Thu, 13 Jun 2019 05:43:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 548916B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so14087219pfk.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=sIxp10xAKQlObyMnzS+l0xFDJXs0xqD2OlWxLPoQktE=;
        b=FFlkq++9ivw3Cy+e49p9PBHlEmlDazfCQ8+Enu5VxA5/4/at8CMv+z9incejZ+KW7J
         MWr/UPjDCnnvybpSbM5n9gNO5juWeOMkQyN7t/zEoHoHOie34IvswF6ZQmfrmXwhFhfe
         c0I0URC6RGRDWtOu+Thy5xP7u8BxtfGkpJlTqLQyE7E6HKxCkWReVywoT3RoPEvP0xP8
         L6+ml9WQe+Cr2XCY37haWqYRXW8+8z4FTvwiKLhG4UVAOV/4DtUhq7ThGEnTDydbizmd
         WftIzwMUplKRZu4E4VYw/4SE6J89f149euL7xXIyHU1qIv8fp8N/Xw4PPxBqada2+LsO
         aqNA==
X-Gm-Message-State: APjAAAWa0Mrb2sqO4roTH/kvKQYvDKY3f8VgyPXkfMk0So7so+dk1HDx
	vNLKNjHtrVDG6Mfx+58EC6qVsbx/nizsvIxc6e6ThPBeV47Pj2KJxk2Q1ilb0FXlND0A+GjncFZ
	pyUwI4zHiGN/AkNFUxUqS1d4/nwp+wvgG0AbUXNYGTbJYsHFFDHcEUqd4T4t9TbU=
X-Received: by 2002:a62:36c1:: with SMTP id d184mr94266182pfa.49.1560419016819;
        Thu, 13 Jun 2019 02:43:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaBPXKR22LjuGzDiOSEIBAGAHacoOyWG/6jvPvS+twKdCnTGeidfhPbOUq6BY2HH2rTcHk
X-Received: by 2002:a62:36c1:: with SMTP id d184mr94266071pfa.49.1560419015941;
        Thu, 13 Jun 2019 02:43:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419015; cv=none;
        d=google.com; s=arc-20160816;
        b=nzMkKO9CWvW8LqEDxExr36ZBj7ku9NTTmbsqvgb7GTwUrrjt1+drSg25bDwJRlLd3C
         7QGA12ipHYuJHxFtuGgAF2qxzbf8NJBvM2btkonrexoT3EbSfN1JhUp4YQyJ6lSUJSzB
         bufZtZ31IxEr3B5Xr8HsiWSjlc17h2u710vF9HBRWYRszvihB/A9qEX2AKlnLCByofwz
         0XsfuHhmjuud7kUZzwbVuqEpGlCW0h+VoZRpD9Wn60xthhvwdUZ/YlWVm+7aZJomtanO
         jnZp88rekXuKS6zqO4SCseHnsoSrCT9LsCwZLVSpDjCaLnxEqjCQGD52EatKJztR3TGm
         DKZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=sIxp10xAKQlObyMnzS+l0xFDJXs0xqD2OlWxLPoQktE=;
        b=RYDipTv0S35vtduHgYmFBJAIJG9boZJupDfocAyimav8G2UDtFM3dksjpUR2yAruiw
         /FZBZeRT2yJS4NaRemQ8UZZvyke4LKEG/M8C06f0P8+aY5IMEImNwGfTJFSzt3bYGX7M
         jMTejcRDM7lYp9ukIoYWwMT7R01VygqGC+K1JDs3HvRnJbkmadJvSXhdMC+f+ULGPS3t
         ouxB45hoFCcZqCFSdLgROgu6qKHekIoJrM52it191JfvKdWpFVqmXTXWZzrIOTJC1Vci
         rQkC5S8OxHZi3EnH1Hu5eIK7Hz14m9sngdJS6cexWjAL7CRiyzHYuoCYuRVrt3qSqBcH
         O5/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LoCmgBKL;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9si2459025plp.13.2019.06.13.02.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LoCmgBKL;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sIxp10xAKQlObyMnzS+l0xFDJXs0xqD2OlWxLPoQktE=; b=LoCmgBKLq0+86d+dCo1Eaxihu
	FRPQqe2yHlfra04CkWk79bWzdne9Hde2IBhWSo9QQhF3eK4LmGH9WGAW7BnUp/iL8OzXIWGkombZc
	7fvOcoXp7QkEpCiD9VbTqr7dqSgXILt90xNuB5peuupqtfYi6q1iDVnDiPHMQdURRu5HBFOiX9wq5
	L3RsgoLeHLKz+Kf3nYSWphbKVJVJI3d2TFciQnmC8YeJgrEkCvjXa8DdWuW/cs6FqS4HdP5AxxWbp
	8gZhWGY9dFWdUfJjtcXk+Qjok7YDFalNZXn4UFc2BKL3nRlO8aL3zk/Qtrf3MrRx9NPVR7EAgcBdP
	tA/JvdTNw==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGX-0001jX-61; Thu, 13 Jun 2019 09:43:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: dev_pagemap related cleanups
Date: Thu, 13 Jun 2019 11:43:03 +0200
Message-Id: <20190613094326.24093-1-hch@lst.de>
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

Diffstat:

 22 files changed, 245 insertions(+), 802 deletions(-)

Git tree:

    git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup

