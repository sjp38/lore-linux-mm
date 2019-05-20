Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A382C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E65520815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Re+W8BLv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E65520815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1BB36B027E; Mon, 20 May 2019 01:58:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACBDB6B027F; Mon, 20 May 2019 01:58:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 994A26B0281; Mon, 20 May 2019 01:58:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 643F66B027F
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:58:42 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 123so9029371pgh.17
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:58:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/SFfD7/IVWCGE96J1VVwYbb2NenGrtf57wS4zCUzGX8=;
        b=dRHqVGQeF3EaKH3psaYx8SA09NYHiJfODwh5OwiIKPxXVyR27jjfxM188jRXWOezCP
         iISEgTw9Fcp6hP3xcaIyIF8ePpMTHwCiIDtP7IK5w+V1Vws6qq9txtQoIUeoTOM137Fq
         6+Hzmf8BtNbCH5yLDdCup6lE9hKPlwZHfEoSTzRxS+ajomjBsWidJqntdBoGv/r6HalX
         PejrL6I38uvdEeoBL8KM6/7P0RuFEAhT1Yh9vUOHNFhf5ie7LsGt+YKIRm/9ZQy+sCXy
         Gnl0r5UOsEJrMrnGsoZqV/Gf+wnKeg89GVqheaAnfwuL9JcieqGbORXN6L0TKr4pJ+66
         N6Fg==
X-Gm-Message-State: APjAAAWS8KLuvnajnPDZ7V/Divj3YEoPkmQ0ESUUxaoD6rbRFyRT1Esd
	YLirUs1dn2lA2giMLDKOFzE1C8ckd4pLM1yyY7BGWP0fXw06OJi6od8H9uTXonJukbz5Gy+IbHz
	ec+6STpTC8D/5LMErF3Hm1fD9LWmhZOt32HzzOT2xS8GJZrs7XKXi7yBQf4qO/q4=
X-Received: by 2002:a63:295:: with SMTP id 143mr73188091pgc.279.1558331922006;
        Sun, 19 May 2019 22:58:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGQeTezAPX3PBSHm4e8PxzbnAt/bfuZUFiF31LmXR9vuyRFi+HBkneM9P5txPtmBL72SGC
X-Received: by 2002:a63:295:: with SMTP id 143mr73188036pgc.279.1558331921118;
        Sun, 19 May 2019 22:58:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558331921; cv=none;
        d=google.com; s=arc-20160816;
        b=Y7pQQnNUmGgjiJSokDBQyqaeOXDOv7PPGiLut0r34fHkA3ieNBBk+tlWFpU6dWq8s7
         XEzHJ9iK9rMnfO+07PSAw2sx6OyJDBhghbBRT49GIillIu2gG/vVT3I8GWIkZHz2Zeva
         wP+AQyUwVeFhqnlYgmAfQacRalQ2Je704i5wu1eXHeYl3xxcE0L8w70viZ30X9VFrel+
         zE2EhZ8qhGm9hDVjpgAayQT/6+XX0E2WSVNQTlpMYgs51yWVbjKgrKru0nMLa1z8HvEY
         Sq/vc5OT5kKQMYnxEgC6p650ET+rN0BhsqafKBOJ0XsB2BTExFqnJ6ypIsLhng/VlWif
         83VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/SFfD7/IVWCGE96J1VVwYbb2NenGrtf57wS4zCUzGX8=;
        b=pbTEF8vCPZykFd1ZcC/D7yR4Ac/Vr0WFEHk0UFfVsEwX4l0vmBtQDUEhzlWVOttgyN
         riTkOdCKJIOWkwZvM2XyqBbZpXB9TbG4k/yqN1W4IfAs2aq0n863pcEcVgQ90qQJ2oV9
         1enBCgpCC3CgRGN6hutcuN9EKiTueNuyajbKtPH1MlmOyVfiklCgXLAeG1JctkVAP/s/
         4Pu9CuQ9Y1j6fAONIY1X0ltYiYHYQVDR/H0rGHj2wyGDgesok5tUdoydlk1X6boVc3kr
         aWjuvm6b+AynE3AfsQsUWupfPt9cx+kAbrHwzkK3Ts+GmzEWVM6CP+vt/KeNp+EF5XA9
         oynQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Re+W8BLv;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a24si16199268pls.372.2019.05.19.22.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 May 2019 22:58:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Re+W8BLv;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/SFfD7/IVWCGE96J1VVwYbb2NenGrtf57wS4zCUzGX8=; b=Re+W8BLvyS1MgoCaapd/OQ+Qwp
	32OBEnKBUJVLUs79jLWSzcz1kHXXyHyqcMTdwGtaPVC5xmto+sVBQqgTMzAmuURhrbIYp8FMJ3gfE
	l3oWMhBHjJ1yeMW3XRT+kjUL9TCBoASPc1/DwkGws7eiwnp5uHSqneVFr2IX7JFO6do7L/tWTt1Q+
	+1pQd6hkn/MqT1RLnUTMwmXA4zOT9ItdA7hEcyB2tI29txo7KqHzqzpwDpAxhlqolJNjYlR1BOTTP
	Rkr/aD1nXh8ArmcikMSKICnWHj9XOcYz83RSs2HQrN6nrBvWm4RnQPggas+3xP5hz8S/E4U4lAclU
	hLiQL/ZA==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSbJk-0006OG-Cl; Mon, 20 May 2019 05:58:36 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] 9p: pass the correct prototype to read_cache_page
Date: Mon, 20 May 2019 07:57:31 +0200
Message-Id: <20190520055731.24538-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520055731.24538-1-hch@lst.de>
References: <20190520055731.24538-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix the callback 9p passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 fs/9p/vfs_addr.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 0bcbcc20f769..02e0fc51401e 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -50,8 +50,9 @@
  * @page: structure to page
  *
  */
-static int v9fs_fid_readpage(struct p9_fid *fid, struct page *page)
+static int v9fs_fid_readpage(void *data, struct page *page)
 {
+	struct p9_fid *fid = data;
 	struct inode *inode = page->mapping->host;
 	struct bio_vec bvec = {.bv_page = page, .bv_len = PAGE_SIZE};
 	struct iov_iter to;
@@ -122,7 +123,8 @@ static int v9fs_vfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		return ret;
 
-	ret = read_cache_pages(mapping, pages, (void *)v9fs_vfs_readpage, filp);
+	ret = read_cache_pages(mapping, pages, v9fs_fid_readpage,
+			filp->private_data);
 	p9_debug(P9_DEBUG_VFS, "  = %d\n", ret);
 	return ret;
 }
-- 
2.20.1

