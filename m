Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A2A0C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:00:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DE8F20836
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:00:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FTkvJIhi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DE8F20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE2548E0002; Wed, 13 Feb 2019 09:00:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B92868E0001; Wed, 13 Feb 2019 09:00:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A811B8E0002; Wed, 13 Feb 2019 09:00:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68F628E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:00:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so1929946pfk.12
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:00:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=VQTkob6N2t7sDyP1BfZgTmEX2COvsZ3fN6pYakW+CplbIA4TGrmpSvPMrOcSvT3x1g
         PYzde7+gzLWz0uAvBHkWRY9xTZnbQYFwzqAW66THSvCmmI0gt3BXRET92GOfAO9tbrDl
         wLmU5UGTyYApZ+vyCZoOScEvT8Ctt/5Q6u7AqUW4iRzjzwG+L9K5z6tcq6T/6U/lBrBA
         MxFAFdWDehik3eTIMbsiAaT8xfbdmDMOU+rfAn4UlrSZ+RZOHMF9GAG05USj9J9LCEdP
         Jb2p3OlbpOUiFmBOhzX3d5OzpqljSeNNVs8cVZMNuYla9MfwCRmPh4T8+wQO2yhWsUUM
         DH3Q==
X-Gm-Message-State: AHQUAuZ8PqklwcxS/XSS0Dv9PLiFM/LPYs/eTRXcau7e54r3Mkrm0HBe
	qEBfJ7zFrYXXpnlbpGU71Jwh0McBE7c/JxPxzBSQeMbCeegWmLp51SnVS+hz+/ucP2+X61X/uV0
	ZTGdgcRcSzpNwrbOegGrGqNbSrMVSSTQfsbYhH6Zr6Xcww993+l69hIkNDFmZNm4AGq2P/troTS
	cuDGbfLp5+YM2AdrwsYFEXobIXD3rV4ELG7+U+1rdLjubqnsRSHz+W0WXMx6C2bCU2uR+8bX2PG
	2lE/spt2rcXyZm9c3VOMPcItGEE7O7oCAzAbjXEtJQvNAHtpFNKlln1kaaIm8dlOQig02zyr9qX
	nWEXKQMS0T6cK6qjhYEdsTmazGw4qNKkkab7XybE5SqTh6yArRkcC19+vtddqZJG+02Hx1HnvoL
	Q
X-Received: by 2002:a17:902:ab84:: with SMTP id f4mr635183plr.207.1550066420106;
        Wed, 13 Feb 2019 06:00:20 -0800 (PST)
X-Received: by 2002:a17:902:ab84:: with SMTP id f4mr635117plr.207.1550066419438;
        Wed, 13 Feb 2019 06:00:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066419; cv=none;
        d=google.com; s=arc-20160816;
        b=Qi9TiO5atT1iolKhdlRoMt5/B7AeVmOXdCPrMgOHk1rv1MKgdEliO/9Umooa6k7i79
         fhH8UdKoEGcMZ1k/E7BpmJXwvV0m57zZm55hA77qVjD+psLyMOjpwlIV5WH4D4CnQHih
         N/r7LwCwcFAh6TVrD4hmxfb4pBaxYic75wLTdTB8LBBletUChmqUTbdbK+lXSOtOodni
         zYvrORhYcbd3z5TUB+Wj94CQEpDT1oWlexxg91lUuK1YCdmvEZt0bXcohZVcdkh4+NBU
         aLyMpo4rF8lyRAsGXZFi3mCf7dlHKKZgbwuG8xwvIxnRHEB7e8PW5Ys35yiOUNb/dSYF
         VC/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=BHekCJIx6AZ079Z4sCJ1l+8cSyzhhV9BjlcNFlZSWzVSxQhjCguU0YC+JJ9epOi+Wl
         fqSX2RbRTy42ZyngloSoX1lo4ulkLNn47ejpdhh3bZCiPr/mzSNYhGqiEaWH0XOqxhsc
         u6NTok9b5vx9jjrxi2MdGffysLdwLM3vTAhj/16+I1uNxhn1zhaRZ52Oj+SehoHxsXhO
         IGSpOSORIPIQfQcWDdQgLYOwuXDViOqnVGZS3LkuKUztrJo+AREd/zKFwvVjdo76/X6M
         0mELUVK66IjJMSJVcYcRtCUeA0qovE9KFjvo8cOLDPQXG6o6S3cqleFvitYqDuNIgy54
         LW5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FTkvJIhi;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y66sor22607625pgy.45.2019.02.13.06.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:00:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FTkvJIhi;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=FTkvJIhiZxuB2UN3OVrDxEf8j3emEZw9A9itD1oPd+tVJ0e8g/nDyZISMfbdyXaAP6
         Ku+f1/oU09s8dZXMCE15EC/lZ4jhE9XpyVezCzRAsRLdy/21AR6rTdyIxoZbfsMxmQYr
         o1QFAdcjEMZ4hpVPbwUZfbKD3bP3YaF5W6bCDSkoV9uE7cMXX9QTOFBJsVTZFBub3vD/
         tLP1kpXdfL6PFeEz95+peYCFGB2V3ZREDDgo2MiHR2YRRTInP7Ujlzf+v8xIEwW/acLG
         YYBPMe+meJlZK/PpLg21XpK/Zqy+ohSuq8qV9XGFBs8K15TIr80jXNZJz+mddYFSLU45
         kSXQ==
X-Google-Smtp-Source: AHgI3IYGzYQtaDAzpRnw4j6/fnsbGP2OWM7ItsKgcpabtFzajnCQ7pxNpaBmZJle8XOTxzleQFh85A==
X-Received: by 2002:a63:5442:: with SMTP id e2mr628034pgm.282.1550066419102;
        Wed, 13 Feb 2019 06:00:19 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id o2sm27521833pfa.149.2019.02.13.06.00.17
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 06:00:18 -0800 (PST)
Date: Wed, 13 Feb 2019 19:34:36 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org
Subject: [PATCH v3 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_map_pages()
Message-ID: <20190213140436.GA22010@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_map_pages() to map range of kernel
memory to user vma.

Tested on Rockchip hardware and display is working,
including talking to Lima via prime.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Tested-by: Heiko Stuebner <heiko@sntech.de>
---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index a8db758..a2ebb08 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -221,26 +221,13 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
 					      struct vm_area_struct *vma)
 {
 	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
-	unsigned int i, count = obj->size >> PAGE_SHIFT;
+	unsigned int count = obj->size >> PAGE_SHIFT;
 	unsigned long user_count = vma_pages(vma);
-	unsigned long uaddr = vma->vm_start;
-	unsigned long offset = vma->vm_pgoff;
-	unsigned long end = user_count + offset;
-	int ret;
 
 	if (user_count == 0)
 		return -ENXIO;
-	if (end > count)
-		return -ENXIO;
 
-	for (i = offset; i < end; i++) {
-		ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
-		if (ret)
-			return ret;
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_map_pages(vma, rk_obj->pages, count);
 }
 
 static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
-- 
1.9.1

