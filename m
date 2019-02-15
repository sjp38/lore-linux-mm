Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 080ACC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:41:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAC4A21B68
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:41:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PZBET/v+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAC4A21B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 520E98E0002; Thu, 14 Feb 2019 21:41:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D2BD8E0001; Thu, 14 Feb 2019 21:41:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C0428E0002; Thu, 14 Feb 2019 21:41:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFDB28E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:41:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so5794297pgq.9
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:41:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=fkK0V/reyLTTxAbdbBNdhE+RYUNUu8F1Tbina4lG6z2hMu+RZWGNaWG39Gd9Z0oKhC
         BCayEdOaBxdLVmS0sAFl7iVcbjjNRHso7MyktXQ2YLEFF7zR/XAKtWRqVX3VFP0n+tza
         uIlTD/i1b9R1ACOTvkkHoxQ/N4ZTAElvCCHc5Q40J7gTDzIvDc2J8Pm2eZVjjwYyp1dK
         EVpoXdmuad0nbNqG7y3E52yHzXdopPrevHkHkW+w/EMV7qXhZugiPSgdi9uxmglJbSOe
         vRBmYF/mzIspQV7XllXZsYZIk4j7AVo5gPEPfLXkGZbIkMlCWwMpF9A35rlPLeo/h+XB
         wpCA==
X-Gm-Message-State: AHQUAubGG8L3mYHpcl7s4WEHIn0bOJRJaNMkRozkG5Yq89cmpOja2659
	qsihra8kphMQ4GU2dhLevRihnKcgs+3aqx5nIuejGICga1t7MnKchOgSZOB9e+F4RS4dNxG9bDx
	hphOdL14I3p9Vg/4kVp7k0pdqDFba6e/OJI5BijQJCMOQn8fAgModwaFhTJtZqKDf7CERVyxpWO
	KeM5VQl6fHvanNBqrJV1QhzPyL7UofrYHukfs+YeTc4y0ZaCPi0bZKkw0gADePgq7sGoUxgeV6V
	IfsFXk8ymhXJjQtk4FiDdTf3Km+7w3qE8ew/TR1XYZI45SMq1R1Qv/pSdLFO3TkLCOY6/pZfJI2
	S2cVaM0S5ZoO2805QMxpme+lTgUxEkDt5NqRTG9aKA7v/9dHkyjG++cLkdeLy8c3urJfAyqudJB
	i
X-Received: by 2002:a62:f5d7:: with SMTP id b84mr7460426pfm.36.1550198465657;
        Thu, 14 Feb 2019 18:41:05 -0800 (PST)
X-Received: by 2002:a62:f5d7:: with SMTP id b84mr7460378pfm.36.1550198464960;
        Thu, 14 Feb 2019 18:41:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198464; cv=none;
        d=google.com; s=arc-20160816;
        b=e8tMJ1poGplJN5MJAwNxQjahFKhGpem25MM7QYnUn6rpm0AR27CdXxegtvXmtLovAI
         dgFlo+iKr5g/LSX1nu93Cq2uYCXWUGz+Q9STjT9aDjOPcto8+l/xVuOzKuv1hGTt0gYL
         oM54vRCKnd/AhDOXGrUPx77agVYrSGnq6K8zODhtYh8L6R/CmndVTyt2omKL+VIVuyGa
         3Z5cjoUPezKkQ76s9mNOXMmPbPVdknKF/RcIjjtTP3uSOgNme+0U4puiPj8ilynd4S+b
         cevAUUnqcUDrjjfT/bYcl2tTh7lQGIHfREcoZGLL8nHfvkxTEgf1Nap04bl3e6DdfGED
         JO8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=APPG3e/Kv0mtlje5grpEySKN9zSNyhbJracZYykHVewvXiYHcj+nVIO4EKPeam/b5U
         48+CmD1bPmbq1ge/AO2jlE8Yvqv6g/+ZwRM+GBx7VJtNT+9lrt4UETs7BjQDodK7SM+W
         Cl5aR1sFIWPa6XwieDGeirI5ySsFT+rfZ6vGtEc4u4gWfn/+GiPRkpajWucHPclBtaoU
         qBH/KEoQ6rzQhdqb9K0LOMTAX9q9oFBSeS2Kpb2Vd3MCqEZ31XAmYc/WRfvS+ssKbSuZ
         s9pna575QAAPu4xC35d89f+3K9ANqbpIWyszaAyqDePE6o8nYhL5nSGG6oAHBBfLRlkI
         ch3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="PZBET/v+";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91sor6555755ply.13.2019.02.14.18.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:41:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="PZBET/v+";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=PZBET/v+AvTm5uI6YhLQd/yhp9OJU4BXs5QA0Gv2/WEpddBD1QACIx3W+qj/R+DwpM
         B3BzpTqjks4wX/579seQjUOZNkBasPTeBbzS7Ts4S8uR/gAobhLKvuuBjPvnZ0p2M1+e
         UH/Gc2iPGBMYC4EV/ODk3qG1i7BTa624G4IbAyHgpQom75nwKU1TVfguAY8NM1SpQhag
         t/bnF90mVuhLmHwSRidYkQGL4uxY7KCT7jqdywdvHspXzYeX6exXlLeF+WVbzBFla7Za
         xrpAZoUBgGaI0ABuhCyNn+4AoykbvyaUO80m2jJbnwhHLhgC8kP1xoZ96ASplt0w6m2V
         UyKA==
X-Google-Smtp-Source: AHgI3IZkR4bUjIEoJN1Iweg1I643mATKe+Qg6hd5B30hfMqsOz0sR+gJKonzI4eh8rnzPur2hIb3aQ==
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr7519491plv.43.1550198464676;
        Thu, 14 Feb 2019 18:41:04 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id g87sm9521109pfe.43.2019.02.14.18.41.03
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:41:03 -0800 (PST)
Date: Fri, 15 Feb 2019 08:15:24 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org
Subject: [PATCH v4 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_map_pages()
Message-ID: <20190215024524.GA26405@jordon-HP-15-Notebook-PC>
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

