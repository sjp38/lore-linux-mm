Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4FB2C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 865582190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="j+GlGmMr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 865582190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E3608E0005; Wed, 13 Feb 2019 12:46:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BA688E0002; Wed, 13 Feb 2019 12:46:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45A3D8E0005; Wed, 13 Feb 2019 12:46:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 064238E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:42 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f5so2166496pgh.14
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q/GsTlT+ECFpftqfq5k/mQtxX2EW5CCRqGhMzVEtitc=;
        b=J3EAGqKeXwZlLr2G25SqZwgx4kOIyxj0jSl/jc3Fby7/rkhzz8Mn7/M+EdZ0W4OMur
         23pb/5HyzNtQt6hWCmF0xX/WNjukVjvK+xgRupq/SbD9rvw58QZok3BgE2QITJKocZan
         f2QeUjO6ouluhBpNaNO5u2Qu0cZ/aB8PCIb/j53Ptbey0kPCkqpYSF6RXpSNdJgXqMuX
         st8+7AvvHz/Q3eF0w6p5H6NRlQ1BgQdRvCF6H/10j9iLVzDHd0RcCHkqdJkqown3lZlv
         uPiWO07QwR9BvZKHJKWOgMp+Jz2mHh7gthHFYI3kZvl2SiVOMRm82deJMoBcMGeOFl0z
         Q9pA==
X-Gm-Message-State: AHQUAua/TWphvFjyIvInG6qt/eo4Yt1Cs9S9Ktn2x1rshyjH/Jn5ECU+
	BEpbAobLYLk0sUWbJP0kUXVUNs5ulZi8tOlCGK67UraRUBnp9jdnVR7yDnTY0MkyMMDxrsU9U++
	jSfRkIGcw/mUyp1lP3sJM/EEdb/Y5YW4Gnftj2BtRSPLxbcK1oSc4dkZ/QetO3Ro=
X-Received: by 2002:a17:902:7043:: with SMTP id h3mr1622202plt.213.1550080001669;
        Wed, 13 Feb 2019 09:46:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCR5p8XUH4RENIx+IQjogefsHS6LSPpIErlKwb54K+BQoaA0IfpqgPrnNQddTFyIyofpqi
X-Received: by 2002:a17:902:7043:: with SMTP id h3mr1622149plt.213.1550080000935;
        Wed, 13 Feb 2019 09:46:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080000; cv=none;
        d=google.com; s=arc-20160816;
        b=OSbV7kQPGOQP7Xv/2xT0spPDtlBngi0+5gbMToPWgMxvn7ZMgeOhvo8WzA9wgxaUks
         go3XyBqEXurSVT8naHt0HFrS7cAi5h/ohuEUPO/rK+IG8ZtAht+5gwt1t9obZ1gGihUs
         ZmWxe5acqMZHo4gbo06xfQs8QIjGRKCbS0+sxVd0sENr5pMu/feBV/uk3TsVDTbxxMil
         1n2mN+C9d8e+iga0ldMTn4NJhXQSbbAlHIxsQXAY3rnzRi5laBCrM79ozZg67I+liMbH
         1V6FPpQ+j9fLOtV0j7DZKEBCx+I7Ap/lm60EyPA9tIquTTHNMszUxT3vELR0unaasUvE
         f/zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=q/GsTlT+ECFpftqfq5k/mQtxX2EW5CCRqGhMzVEtitc=;
        b=LFXZ35y156v77666IOtmT0UpbDIp0q2hP7b4d9v1T1DlvNYUrubeIRBIBdqgCNwsEa
         FQMCBhhtXj9aT1FwuLnxHC6TSh1jpFm3YVv2dIV9ioMbff3bRx20cXtJNXaDEUfw5iD6
         Uo1DN0ats+WJhVId+I8i3mJrFBYLWTs5h6eOesyvR5W7aVBfNnpUHGWzaLLYACco6l40
         GaYZlXtfjZzsD7dgvSOk05NqpAgYbFEVR34PMdwA3wE+slSri8lS5aROlo9eX9qEfH/f
         iR/j9v6aVKCVU1bkRnbg3mouP4pLYSCvmZKjxpZzHKmUtjgw6OrE8hLf8/ODoc0tXJbU
         yFjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=j+GlGmMr;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b8si15118745pgw.561.2019.02.13.09.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:40 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=j+GlGmMr;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=q/GsTlT+ECFpftqfq5k/mQtxX2EW5CCRqGhMzVEtitc=; b=j+GlGmMrZEMKKkxVGVeWrOeCNf
	OpvdrArdcf4v2LZLSf8deFfFDjNklkFFvoMrGpyc6bh0ARkbv9TC+LEpMnFI7zyTEVyR+jJXBdWEO
	WjebbfBh/vKLmC+YhE4I8h8MDF1llpL4RWEDnfZwipht7XoE+dQs2ffjzZG34cnAbssJTfldObG+D
	yAJ1JnHattAnJAB3xPtzpm6CmdyI60v8334Cn3z8QQi+Ykgh5PLV2TR0Kn1d3Pj1WyZvMLARh3FSA
	BYGLda+8yUMBdyuJ4+JmotBhqZDG5uyVi2R6iUU0mkH8nTotRR0mvr/fcBbHawpNMWaV5OLjeUV2l
	Hs+Op+pg==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtyc8-0006cs-PL; Wed, 13 Feb 2019 17:46:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/8] initramfs: cleanup initrd freeing
Date: Wed, 13 Feb 2019 18:46:16 +0100
Message-Id: <20190213174621.29297-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213174621.29297-1-hch@lst.de>
References: <20190213174621.29297-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factor the kexec logic into a separate helper, and then inline the
rest of free_initrd into the only caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 init/initramfs.c | 53 +++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 23 deletions(-)

diff --git a/init/initramfs.c b/init/initramfs.c
index 1cba6bbeeb75..6c2ed1d7276e 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -518,37 +518,35 @@ extern unsigned long __initramfs_size;
 #include <linux/initrd.h>
 #include <linux/kexec.h>
 
-static void __init free_initrd(void)
-{
 #ifdef CONFIG_KEXEC_CORE
+static bool kexec_free_initrd(void)
+{
 	unsigned long crashk_start = (unsigned long)__va(crashk_res.start);
 	unsigned long crashk_end   = (unsigned long)__va(crashk_res.end);
-#endif
-	if (do_retain_initrd)
-		goto skip;
 
-#ifdef CONFIG_KEXEC_CORE
 	/*
 	 * If the initrd region is overlapped with crashkernel reserved region,
 	 * free only memory that is not part of crashkernel region.
 	 */
-	if (initrd_start < crashk_end && initrd_end > crashk_start) {
-		/*
-		 * Initialize initrd memory region since the kexec boot does
-		 * not do.
-		 */
-		memset((void *)initrd_start, 0, initrd_end - initrd_start);
-		if (initrd_start < crashk_start)
-			free_initrd_mem(initrd_start, crashk_start);
-		if (initrd_end > crashk_end)
-			free_initrd_mem(crashk_end, initrd_end);
-	} else
-#endif
-		free_initrd_mem(initrd_start, initrd_end);
-skip:
-	initrd_start = 0;
-	initrd_end = 0;
+	if (initrd_start >= crashk_end || initrd_end <= crashk_start)
+		return false;
+
+	/*
+	 * Initialize initrd memory region since the kexec boot does not do.
+	 */
+	memset((void *)initrd_start, 0, initrd_end - initrd_start);
+	if (initrd_start < crashk_start)
+		free_initrd_mem(initrd_start, crashk_start);
+	if (initrd_end > crashk_end)
+		free_initrd_mem(crashk_end, initrd_end);
+	return true;
 }
+#else
+static inline bool kexec_free_initrd(void)
+{
+	return false;
+}
+#endif /* CONFIG_KEXEC_CORE */
 
 #define BUF_SIZE 1024
 static void __init clean_rootfs(void)
@@ -642,7 +640,16 @@ static int __init populate_rootfs(void)
 		}
 #endif
 	}
-	free_initrd();
+
+	/*
+	 * If the initrd region is overlapped with crashkernel reserved region,
+	 * free only memory that is not part of crashkernel region.
+	 */
+	if (!do_retain_initrd && !kexec_free_initrd())
+		free_initrd_mem(initrd_start, initrd_end);
+	initrd_start = 0;
+	initrd_end = 0;
+
 	flush_delayed_fput();
 	return 0;
 }
-- 
2.20.1

