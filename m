Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4282EC282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0049C2184D
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:06:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VJa1+zh8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0049C2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BFF88E0002; Wed, 30 Jan 2019 22:06:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76E7A8E0001; Wed, 30 Jan 2019 22:06:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65DB18E0002; Wed, 30 Jan 2019 22:06:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25DB78E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:06:29 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 12so1279178plb.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:06:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=fve/F1/lKXEnfpzre5B+d6239UbIM50sDNUC8vj1UvQ=;
        b=UiU/vS/k/PsO2pufeDlkgKpUtwn3UKb+Um5dBviQDKD7DybJ3qA6zmXAAe4dEH1X7n
         psXZH6iMHT4cMnS3OnRr8MTva4StCCEXUV8KN+8OeYrzSjSnWBBJ/nVbusRHbbS+lLJ7
         WiQj1nvEYqXbHsZRFittgdfmi4C8AltwhyUHSdUj+AfmGpl6YnW/nG1gNq1cLKB6Jho6
         C6usg1eUh6xAA9bC3U8Ia8tui6gzjb8MQam5nr7Jnqx62FgQLvUU5NDgJNrFPq1VqUs4
         uMNTciCTWDCOjD8m/0wjmmc+tjYbRpxFnD1Sh80AY6MwYb/rcA/MHMDMJot/R2CqLtMc
         eE8A==
X-Gm-Message-State: AJcUukfpXcKJ/VSQw8Ev64IEmFa4DDgyV3puhwNQCnfu1D259//upVPW
	ZyIxZNUZ+pztIU4KxXQbodrSKZIJTNXdp+oa+K+E/Sd4ZajrW7tacyRAPw2tzRj1oWJ08zVAsw8
	u6U18aKESPcpwTi4wfmDmkyfP5GEY0VjzMfRnDEOxBQxeLTxTUAtZRL0xI0l4UdkkayoEoMYwaB
	HnS5Xp+8rw67pdBDxJwUq/O2jh35yIkKlXZmpg6j+h0u27dfG8iWzIkaCpFPTEI0m+R0VnR3Zbp
	QKyBhhNHRPG60wQn3r0lAOCkqSwhCmt7LCptZNG+LaQ0dwEG4QIldHE7fKQXM2R2t+1CLlVFgAU
	1DEW/04L7LamJhrGzcLHgZSHxy9kp0IN+/6vnXbrDUWa038pFxQ8UIt2EJy0rsluTTYmPBCbrKf
	2
X-Received: by 2002:a17:902:5982:: with SMTP id p2mr32735660pli.39.1548903988826;
        Wed, 30 Jan 2019 19:06:28 -0800 (PST)
X-Received: by 2002:a17:902:5982:: with SMTP id p2mr32735621pli.39.1548903988088;
        Wed, 30 Jan 2019 19:06:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548903988; cv=none;
        d=google.com; s=arc-20160816;
        b=KRHz4rAOak8QNMqhtd0/w/lsr8meODKYvQdBSx3+GQNJQqMXfzdnNJPoA68NrgbbIQ
         NydtZ38Pc3An3msD1MGgW62uxSude17gNpaNgSY+KsL75x0LDbwG1H5gIrYeIaq/388J
         iFsJ+tcmZs0KlFkehwPtxhKEidpWLQm8CRnsPWHH59dcr4JXkYI5AIFp4C85IeNCL1jj
         /vBWto2RN4/AyCTqAxARG+Ux7dk2gH2ZLZpQEc2HrOmlVfDhTbY4iNtdPqqPFKpPEdrx
         CJj2gvE0xBfPB53/q41PN/hk4Ma91fB4em8AyU+cB7Z4rfMR0miUnsz7k/sSaqRjbhoV
         eKYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=fve/F1/lKXEnfpzre5B+d6239UbIM50sDNUC8vj1UvQ=;
        b=y+oU8rv4671uEB+tFHe2VN6OxmjL5Cz6A4jlLceLZmzxZc6hrvyRj/rujHzGtmdHje
         NHZ9VjnLnTommhHFc7Atp1NPmwmM03kJQqhVu23fssRKMv/3HxWGXVZwrKmbIwx7utgw
         PTNT9kimZCLirYd9Xy/Krh5CziYJHL+cn3sppqTwKSCXJeabG6we9kvlCmijCpNTYhCt
         Ksiqc7ol4Sv2h4s7vF6ZSPXzaZPEcEfdNwRyd8Un/8HpWwSW3iXtX4T1ptf0XKVL3X9W
         Zd5Vh1f425HAYoPDZgef5aqMOonCrWRudYhXVx6jy/cNRJ7TqAmPqUtCKTxOlQE9j8SG
         g5dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VJa1+zh8;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y6sor5422501pfi.19.2019.01.30.19.06.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:06:28 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VJa1+zh8;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=fve/F1/lKXEnfpzre5B+d6239UbIM50sDNUC8vj1UvQ=;
        b=VJa1+zh8xHi3tI1io1YyR1jW4Ql0L2HM/0G/TqGLCYIRuEUfaDMSQLwWgfnv/q2VCK
         iMQgvcHSc2/MMEr41Z3VcXIJpBynXvCLMm+MCb5Ony0kLh1P+43S1EyOZ0c2VVcXfUDi
         zyUHlPc92S25kuxJL0xxi6q5K7621sWC7v7ZPljG/f/9EmAD7+iDx7aFSG3OZ8ScP0cF
         VzOGvcgsG44tSmhzqBnqDDYP/OTdVImNeD06R22jMcUhnzLmqtpjiveuyfIVjBd7x9Me
         M4s/fGqqA5tbzFW8w6RcVcyXN17XcXe3Wf1t1LgEPIqHODKKlYApfWHRPjE12iaJHekM
         stRg==
X-Google-Smtp-Source: ALg8bN6rRzXK6nfBRBSHhIlA85333gGdTjbHnrt6wuJpi13BssALmTS8VMglE5ur30io8jYwjS7LDQ==
X-Received: by 2002:a62:1f9d:: with SMTP id l29mr33146546pfj.14.1548903987795;
        Wed, 30 Jan 2019 19:06:27 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id v2sm4236663pgs.0.2019.01.30.19.06.26
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:06:27 -0800 (PST)
Date: Thu, 31 Jan 2019 08:40:40 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org
Subject: [PATCHv2 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_insert_range
Message-ID: <20190131031040.GA2320@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index a8db758..c9e207f 100644
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
+	return vm_insert_range(vma, rk_obj->pages, count);
 }
 
 static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
-- 
1.9.1

