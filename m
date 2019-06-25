Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47DDCC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D06C0214DA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="X5F7mPiW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D06C0214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 240166B0003; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1997A8E0005; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087AF8E0003; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C05F96B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:47 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so9307237pla.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=f4+tMQltbicxd4ALT4Rx3OQZpZ5MP+Ju7Cl4XLKLtrM=;
        b=uTlYhDsnxrAjIfIo4quM+7glBOukAa2rdIXRmtdT52FIYTc3LbJMkmEvOWBbOgbAFQ
         TPx5on6+nrdYmGMMhjsCbx9xS4awSYqiwmZn2T0oLOvZSUhLxQzvmZjrmMAq50PVO0AV
         4p8FubR5wEU1jSWVBhwemfzulDR5YQhjzuSNYQDvIZgLUxhWRXZl5nqQyCeW+emPfyHI
         bCSD4YQYzkQHzoU2y54E+RWsl92KFaYOSzJP7iAGjlwZAJ+pjH8o76Ojjvp3Kwr18P8f
         sGaAh7R+/0n27ReA28GI9H+zm/iFz94wlVbJh8JtMt5EiR4ib8ZhRVz2+2DxZwh3zorA
         5Wsg==
X-Gm-Message-State: APjAAAU+2F/0X1/pI4RAogtoebtccucO8Q6SVUAj3nfDg7UDYgry5KWq
	0RkUc2JU08PPMy/iIh3ZCjRBBqeYzEnLcorK0TyN0JkbwbSgUrpKKTIVg7OEUNXyP5dn3Wa3bFB
	EQvZGGYPQ+1ARJIwTdnpVhwgLnFDhkITObXq9cs3kGhnPfiDNi02pxJRB6cKZRsc=
X-Received: by 2002:a17:902:27e6:: with SMTP id i35mr153978580plg.190.1561473467353;
        Tue, 25 Jun 2019 07:37:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSAAXqR23VRmHHYTBULTvfsVKo+2maVAIeY/NhmfjydIgnrxnafqGMv2YhXA+bP5rQ9SA0
X-Received: by 2002:a17:902:27e6:: with SMTP id i35mr153978510plg.190.1561473466558;
        Tue, 25 Jun 2019 07:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473466; cv=none;
        d=google.com; s=arc-20160816;
        b=etKC2u2ExyicidMK4QGp27jy8B+C4hG3iSx5loK1cWpeDxI/ujVMLR+qFXl7mAFeV+
         B5J2vqzLgqXrDYOo5b6v0pH4tOtiHmjQ2LDoAdQQsZqaMgAM2LNflEv2qRQNZEmcJtTR
         EDYnOts0TQzpU5KMtcc0Ac86relu6E9krBwiyOrn5iilVcmxFSvyJJRZY67QurqWrcMw
         dLGlaUdwxx9dBkoFJ3MuCgcSUZ2lMnR2tXLZ7NH5OVFhfXS0GZzm3e99RddDzwX2OMss
         KqAlGwMamHbSBAug4zFIaJTIxn7rmg4mWOwOOujTaZxePe5NrvS+UMUCJ63OxWwM/9cT
         t8qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=f4+tMQltbicxd4ALT4Rx3OQZpZ5MP+Ju7Cl4XLKLtrM=;
        b=Te9ymx09aXfv0Uw1KsgdnIET/CFyU6PlRYf/h6IMNCRqKg33K1vj3FGfMwWY+fUpYY
         qU9J4c5Mr2zlV2T9d0ozVFKbAPVEaCjcal7gRtvn5e49Eus2XEBMuUZPfDYJPHZ2yRdy
         NJwOR+nP1chuUgZ/u67MLxebbNUvozG7CzVbW80rLHLZkGZzMdyaRI51P+Sk+q+Z6+lS
         1KNyLGvXfwBhbao6Y1tThwmNS9dBhuk/DaUVvL5Tr38YlvemeEGaFRN3M/6+m1v/c/EW
         K4kPDu4vFaxQGOASMHpYdJyYZMr3BlXXFf13byTYfHF3IYszv0nhnSRxJttYjVEGX+/V
         JNTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=X5F7mPiW;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b17si2964542pjq.20.2019.06.25.07.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=X5F7mPiW;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=f4+tMQltbicxd4ALT4Rx3OQZpZ5MP+Ju7Cl4XLKLtrM=; b=X5F7mPiW6V3GpB2Dzy0uuiLcr
	Q1nr0Z/bXKkYgiYtfSjd+rSbKATjF3Gdgd0mN3/vYrEMO/Wc/SRIgcRhLlvYadt94BdYFq6jdw/nP
	AwhtIbzcbLCYlOTHif1Um8TqdW1pmhZSHImvIPJZMwHU/da3RXnjCfqDaWAe3BVBdltBFNznvQFOb
	sRb3NYKvhSFrwhB734qJDCQWStHZJ257YIrBp8b33Xces5frH9sCRfyV0D74Bszew9YprhF9rXvKm
	VWnBYQKDFqJSt5VR8xllP4qXZjXg2ARWfiP1d9zuj7aazxYYWmVgGyU3SQUIS3Xwx2oVWJEAJo7C7
	SL9QNydbA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZR-0007x9-Ll; Tue, 25 Jun 2019 14:37:18 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: switch the remaining architectures to use generic GUP v4
Date: Tue, 25 Jun 2019 16:36:59 +0200
Message-Id: <20190625143715.1689-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus and maintainers,

below is a series to switch mips, sh and sparc64 to use the generic
GUP code so that we only have one codebase to touch for further
improvements to this code.  I don't have hardware for any of these
architectures, and generally no clue about their page table
management, so handle with care.

Changes since v3:
 - improve a few commit messages
 - clean up gup_fast_permitted a bit more
 - split the code reordering in gup.c into a separate patch
 - drop the patch to pass argument in a structure for now

Changes since v2:
 - rebase to mainline to pick up the untagged_addr definition
 - fix the gup range check to be start <= end to catch the 0 length case
 - use pfn based version for the missing pud_page/pgd_page definitions
 - fix a wrong check in the sparc64 version of pte_access_permitted

Changes since v1:
 - fix various issues found by the build bot
 - cherry pick and use the untagged_addr helper form Andrey
 - add various refactoring patches to share more code over architectures
 - move the powerpc hugepd code to mm/gup.c and sync it with the generic
   hup semantics

