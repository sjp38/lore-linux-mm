Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD8A4C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A5AF2086A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DvPiad/R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A5AF2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A4036B026B; Mon, 10 Jun 2019 18:16:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 454416B026C; Mon, 10 Jun 2019 18:16:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343216B026D; Mon, 10 Jun 2019 18:16:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBA366B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j36so7740903pgb.20
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=zx6pM5Q0d935TOPq+RPAUxBXf7tdWkzo4n4yneWvKE8=;
        b=GTcd9GAZr48vsiWfPa+tFcCyrF1DYlfHenW4wOZxrUsDy3Kv8orx4X0MbqU0aLvPaw
         ctwMJPekLZ3LjTWx9u3auPNDlc31lUG0pMIsraBBql9XIB2sBFwbszGgdUWSKAX67EzQ
         H1C8DtFwNYFnNyfJdDtpew+ssDz0SuNsr1HkpW7hFbWFuinpMxoxyr1Q8e6inmRBDhms
         uSZIJKGJaGwxtm+xFTqokdWtvoFMYHjucyJFevII7MOqPBluXrEskEV3JhFcYeq/+LOZ
         UQ9YSfg40BhQsSmYGmkKHiqruniXxROSaD7+gUKg5CC/WFVuIISkAZVbtT39zncEhChN
         Y6HA==
X-Gm-Message-State: APjAAAUDEj0gwCU7T0VUV8qfYhvFDMSVlWjnHvKI3WIw/pqZhmQ/uLoj
	R+f5s/WxuCmjt0HYxRkJMqjvjsNAENljQp7LiNIxs9OYTfER1qvWAo4wqveVlqLVOZYvvp00Imw
	BNRk9rPAdteBWBnI703ngXjuFnN3lFfAFxYSreLadrfIK8xf/MaZkmNv+RG6Zotw=
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr71219005pln.226.1560204987620;
        Mon, 10 Jun 2019 15:16:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAKZtqa6LzTsSCxg3zyGBVpKqSnk9F6HJe+NiWShNCAjYhOJVC2gA6NA/yKQocvHnhcFpD
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr71218939pln.226.1560204986892;
        Mon, 10 Jun 2019 15:16:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204986; cv=none;
        d=google.com; s=arc-20160816;
        b=crq0pdjT/XITKsfqiYOjSMzhcncvhW8SpcW64Uj3LzuqGSfSxxCM904jIfUvL6pnyi
         I9QUnaidvGhD3T69jJu4HFuDOrGUT9FDFKUoT4EOo7JrO3BGCCQeactOGYL3p9u98nQS
         D21M4Rsa5Xh4guYZOPJxIqUYL9t0HGpFkfSPst+pW/1GGnW8503R+qgq72ckA5HQxQeJ
         LsiQ43tgj7XvAj/qPUnClsK1RdQ370y7miy5vZFc3/Sk0Vbb/lVQUPfv2WR4NlY3V8ol
         50uEZOGLezB66BD/kxUq/iDhR6M5lOmuYC0VfDrgkLQ3dFP2u2Imr/0s3w6oBh+LXjUa
         K8Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=zx6pM5Q0d935TOPq+RPAUxBXf7tdWkzo4n4yneWvKE8=;
        b=RhsgP6CknvQoahwODe47B9LY+tOT/CRB1gufNfLlSz7Wri+rDJU8QT5KmacEmyktE6
         gnplDunebONHx18BbO1EsrvPo045dMaf6Ct4ENnLKV19efEwbYlq7Mjf2Vp+FloOXI7V
         8sT24YbV2jzXAxFJK5liW6QqE5ZcomO1yPtk5XIdp/+YTIgcLQHuWYrIm0Ws5XJyexxX
         cGGF9zSuopR7IIni5NCvzsL807HyaOS81jXA69GrLgZyy6KUS4cu2f20AipzVNyUPtsD
         IHz8slDqFbpJ9TENVueimoZmBnCF3RGrYWYJ5f6HxsvrKoLppMjWTOxKCzJFjhv30cOD
         IwqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="DvPiad/R";
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a10si11092864pfc.55.2019.06.10.15.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="DvPiad/R";
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zx6pM5Q0d935TOPq+RPAUxBXf7tdWkzo4n4yneWvKE8=; b=DvPiad/RAZ1jFjbOhh4OEG9L9
	5UO5ZRLO74edX8/NV9+fgHjUJ4NNc/20IQ8WfZWSGzLWJC8SB065dr5G1bvJ/HTR4OyNtcY9SpW9C
	ceRkOdw117OTWdgYCTqcbgjsMKjU2eKkdpn9952jH1WprdazNhfvH2C5Z5h1OOakjGm4bnNCcD0Bx
	qimmIoJ2fYxPikvj12CQwyIKcUpgz+jxPF/vb0/IvOKmmhv9d52PgOfIHCKW8f5rl9LLHlEylbltq
	2SbAHhXMmSvgiHWKD1FnEXdyDPEqAxd6CVVC6GLRGwW9ySlca1WHv7jxPMfYs6jXj3tWh/Tq0vaVS
	yVPWh+9/g==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSaV-0002kS-NG; Mon, 10 Jun 2019 22:16:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: RISC-V nommu support
Date: Tue, 11 Jun 2019 00:16:04 +0200
Message-Id: <20190610221621.10938-1-hch@lst.de>
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

    git://git.infradead.org/users/hch/riscv.git riscv-nommu

Gitweb:

    http://git.infradead.org/users/hch/riscv.git/shortlog/refs/heads/riscv-nommu

I've also pushed out a builtroot branch that can build a RISC-V nommu
root filesystem here:

   git://git.infradead.org/users/hch/buildroot.git riscv-nommu

Gitweb:

   http://git.infradead.org/users/hch/buildroot.git/shortlog/refs/heads/riscv-nommu

