Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04550C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B652E2190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gQxXEPxP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B652E2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 323BD8E0003; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D2AB8E0001; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C14D8E0003; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEC268E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:37 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id i11so2175217pgb.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F4/kzC3jhV0MG/GU79iUnwgEUzLi55LAygewrfHKenM=;
        b=dc0qsAfeehstPghqVXj8/4RUM+3tZcXcgMvGSs95xemVWbz5QrDgi0EnE6ibH7Ss1v
         brWo8tsSxOi7HOb0rQp4JLvS5aaOz2vkPtNdpoI/2MLrLm0CwHRBOlaezEUo12rQ66nN
         sWSaZ5ofkNrgUTJLzjacs7sSUUkUheeH5HTY4p7aDdvDAXUB9KcGFsOPsm5iXkS2PMyo
         OJ2p/e6E4+pFsWmZTybGXcP5+2HVimM10Qo6eXkK1/7/Pxem/w15T1TjkPnECq6neifP
         fmHWNHQW1IeQ7TEk6P5abHHazAm/9oOmt0C0sXPksPXAd0RAgigb+inHpXcSXxy3mqUL
         +zCQ==
X-Gm-Message-State: AHQUAuZqkPe0hMj3E1HInGfSy3HE+3WP2OpClIHJfKnuv5/3hapMBPID
	+oABMnIGWFqxFjlXTyedb4kSfS1wqbLzLlrUuZYpcjuk4W/vSNHDKkcvIdinps2Y0mddX91o33B
	HgOw0bguIuLEADez9ReaVnjIVCaQeYQ97n1Le9zYWvRiY2bNISqlvaeE2r5BA5pU=
X-Received: by 2002:a17:902:bf44:: with SMTP id u4mr1657260pls.5.1550079997319;
        Wed, 13 Feb 2019 09:46:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbchJaIDQZTz71HP47iCZ61a8WuKt3qgIcEOdGhqcIzcamsEPnom4OV1PtFE8U4Lih+je0M
X-Received: by 2002:a17:902:bf44:: with SMTP id u4mr1657203pls.5.1550079996668;
        Wed, 13 Feb 2019 09:46:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550079996; cv=none;
        d=google.com; s=arc-20160816;
        b=j4JuZgN56OdC5ZmMH4UXNBwg8sLVR6Ul/LwSvifmXwB7h9DjyN5DXKi3ozAeFcQGwK
         lJAMku4x7CTF2pWT2gNhhypeDBQHQMxH51ejPbyI5o7ttWdgvrTTz5aDCBL1N408Pb6q
         Ih3EE3kdh6H707AIP6fNyh9QaMaLIW2SmUW3vCtPm0qeLRNTU3JE+tHDZF9ppbPBKKSY
         mYTVCUJqVaTunHXYQZOaROku4u+Da5OtElCXO34rOiajsXCDyTO+Josb7ii1OLPPcYiz
         sw/6WDTMVz5jPfcr6nfKOR8yQLh4xE6nMeH19giyaffoWyAbq2QhxUcNe5QXosjNqM5R
         6j3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=F4/kzC3jhV0MG/GU79iUnwgEUzLi55LAygewrfHKenM=;
        b=XX5qLBvQgkdg1uRjqgGxrRcZhTPdC2zqpwc21rxVU1KuvDhbUsl3AE8Y7hFYSNnc3f
         IYvez7Vd4uDoti0RHoGeHPMh0SgaMqYgd6RCk1snWScKylPjZo0pi+bMgI68DN6T7oqv
         KjtmNaMhkNDmoCCZYz8Jc7bfcW1eO4xMIDxR/ZEl8Wig5sEyFGFgfYAukKWh8yQiB0GV
         1zoltfox8pDBajn8IMGM6h8O/kncHp2xc6LlBRNjZ6a+58aZ3eBfPyb13E44bOjRqKe8
         Rb326wqHtBA/YVxXYVJyEWfk9W/FvX7n2Q57RoD2W+bY7kwI496kvQmXyvGdKJbDHRgR
         tZqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gQxXEPxP;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l7si16386178plt.25.2019.02.13.09.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:36 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gQxXEPxP;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=F4/kzC3jhV0MG/GU79iUnwgEUzLi55LAygewrfHKenM=; b=gQxXEPxPM3+F0T3U4GrV1QDT1/
	G8JSf7aTTJH0Wm8ThrbxnywTU+9gC3SCujimS7i+k4jV+0kYzkR9T5bE6J6qMz8R69EvvquZ+BYkC
	giznrEBe2MPuigbD81fsRbVr20J+tnbTCD2ElwFoZQRaBsSxAgXctZfP/N8afNaMWbw7KUg7rSgRw
	imGWvaU6BoLgo2suacMCl1aoWRUjEc3wL+ynJkG2OzcA1/4w/ENho5QWA85w7bGk3MwMH5GpzyUgv
	ndP++oI6sc5Np/qaIrkyzz5nJyTdWXsYisJPrpGx0Hv4i1uHeXZ3/u64uiafHU1uWuyMbE4k6j6Kx
	1YSxWilA==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtyc6-0006aL-C8; Wed, 13 Feb 2019 17:46:26 +0000
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
Subject: [PATCH 2/8] initramfs: free initrd memory if opening /initrd.image fails
Date: Wed, 13 Feb 2019 18:46:15 +0100
Message-Id: <20190213174621.29297-3-hch@lst.de>
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

We free the initrd memory for all successful or error cases except
for the case where opening /initrd.image fails, which looks like an
oversight.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 init/initramfs.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/init/initramfs.c b/init/initramfs.c
index 7cea802d00ef..1cba6bbeeb75 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -610,13 +610,12 @@ static int __init populate_rootfs(void)
 		printk(KERN_INFO "Trying to unpack rootfs image as initramfs...\n");
 		err = unpack_to_rootfs((char *)initrd_start,
 			initrd_end - initrd_start);
-		if (!err) {
-			free_initrd();
+		if (!err)
 			goto done;
-		} else {
-			clean_rootfs();
-			unpack_to_rootfs(__initramfs_start, __initramfs_size);
-		}
+
+		clean_rootfs();
+		unpack_to_rootfs(__initramfs_start, __initramfs_size);
+
 		printk(KERN_INFO "rootfs image is not initramfs (%s)"
 				"; looks like an initrd\n", err);
 		fd = ksys_open("/initrd.image",
@@ -630,7 +629,6 @@ static int __init populate_rootfs(void)
 				       written, initrd_end - initrd_start);
 
 			ksys_close(fd);
-			free_initrd();
 		}
 	done:
 		/* empty statement */;
@@ -642,9 +640,9 @@ static int __init populate_rootfs(void)
 			printk(KERN_EMERG "Initramfs unpacking failed: %s\n", err);
 			clean_rootfs();
 		}
-		free_initrd();
 #endif
 	}
+	free_initrd();
 	flush_delayed_fput();
 	return 0;
 }
-- 
2.20.1

