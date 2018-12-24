Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE43C561E6
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:23:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E66221850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:23:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TRR1LFZv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E66221850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F77E8E000A; Mon, 24 Dec 2018 08:23:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A6368E0001; Mon, 24 Dec 2018 08:23:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3987C8E000A; Mon, 24 Dec 2018 08:23:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBA1E8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:23:57 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so10803596pgb.7
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:23:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=w2N1lFnP7lwgyibZCv3zxC5CB8Y6AOTQeCb4v428osI=;
        b=jg8S0iH/aHBhzsdmmwVJRrgdg20uG/+LiItjz6Uc6KLp5mIgrNDQheUhtbsWCICkau
         6qV9A6MAP2mHnWwKS36vVaxtZ+cWyF/xHv5fPVmMPbJ8JSJOOiARPfuBn8xfEZqt3TzY
         5/V4H/rMrU7yVqnR52CkD35cwqNEK8m7TY6PlV+ftT1vSurVcYfv9qzRYK+SJuHRPpsU
         Eok9et0OtfzCHKb/J6xFYaVK9q9mxP4h6WNJHXL+rUecW5lcFFK6GpmVViO85RKJoaKk
         ps/+/RrYyPPxeNYg3zCEUVPMpBmwTyaB78ibmrBjxuIA4ZyF/jsoGA/uDa4IPFDfUknh
         040Q==
X-Gm-Message-State: AA+aEWZgU68GbGU1DGo+wpuZYam/95gL9zMs5I3MWxSAEnjAbiXxz1S4
	/cIcLtPjEZjUKOxIvJLc+3hhECblEw7awwIAp6yPq61chnX/TsTjdiTpWkH5Y3kFHKMCBrNLmYi
	H0ga9eZ8nGnj5e7DMmH9R7D2SyrwtdDpWFCGDBFy8vlAV6pu48RoLRUBC4bu5rmsRXNvlUEZFjT
	spm2DVc5yhxx7uM0GKFTsh2a8kmfZePZmzydXA8kCpBwgW4qmAU1gAZZMDOu/XwqaTzOTO2rGXX
	NvnVL9lfJ+65oSUK66SBo2BV1YjSpZWgZBQX0/y/JosWe6Xzt8fqp93G/s0MmzeVMaoKhpTHrXg
	2CfMPD+gDTskZ+h48uGlFi2qNVaZRiQKR4NrWp4hQ995HRiUDN0AD3rD2G+5HAiNO6KA/i+atl7
	u
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr13109291pfc.166.1545657837651;
        Mon, 24 Dec 2018 05:23:57 -0800 (PST)
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr13109252pfc.166.1545657837033;
        Mon, 24 Dec 2018 05:23:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657837; cv=none;
        d=google.com; s=arc-20160816;
        b=pnlkAA3cHvvOzU7z3DbAqIA9uwTenqwGYRSykDd3IGNfuB4TAxnBSxP0c4Jzy+so6a
         M5qKDRpOn35qMq+zA1bHi3g4364K1SFancv4UdYZY/JC5pDvTPUgCSbQ9wdToLzPkKBS
         vVCiQ+MiHWPl1vOEZoEF1FkIIIAVOTQBueu062hckwmj1VZonY9f8UkblUhCova2cgwO
         DziCiEGp7KcuypqrdpwU2aDf8ELSHiuPA+2/vrg23BaZ0PWfFkizcth16jTDe6FlxBN5
         2sCKqGDzv7XNRhCZ1mW8QX++erI/KtQkXpDbVcnzYFHW92qJ3pHDKKDjk9Xg9ZsFGfpe
         udCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=w2N1lFnP7lwgyibZCv3zxC5CB8Y6AOTQeCb4v428osI=;
        b=t1a4ipKWnFSQWoL8CzGMKQUKZ/MwmGLbxmvbjHa8O8gkbWEEDEir3K+mX1hCo/LcG4
         ll10PMR0ZrOVGrKlucEl9T7Dn/FgeYFKOPwqeP2pCSZVe/BLGs4A8U4gQo9R4RhRo4On
         /aMjCJkQGjgKZeW/4ezjISnUTXfTglpbEpEv/kkLFuySTd0JNS1vxlFUJ0208AWk30/0
         dIKKMYH5nWj85EmkIG9J/3bb7amcmYq80tpKTdLbCaWvr7bmO/lYIhqSoOC9Cu4HaTso
         tnQSsq+MfYsZsBQyJZOXLJTEjPxD8VbmsZit+nGjy3PaXhzmYCkudHfT7fntZN4qvHfP
         CE6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TRR1LFZv;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor52849352pfj.47.2018.12.24.05.23.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:23:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TRR1LFZv;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=w2N1lFnP7lwgyibZCv3zxC5CB8Y6AOTQeCb4v428osI=;
        b=TRR1LFZv4DfYv/CLFab1H5gXj9FSE49ggM9pEjq+0mbLtB24XCJVWTEVNxu0Jr9jfP
         aXbKP2W1rQImrZhnsPScKg7NvHRhWsdijVauyLC8/q8oJt9aXNkvOTG+GaQHcE5pxbm6
         /59fC4l6pTS+IZajcvb/jzZViGymmogxlrCI16XH1zhfCvxeCGty+kKPo3aHKl8+RdZo
         MI2IYw/aF6aDHfPUint+1oUR14/QseDL4JSYv2rWDOEAubkmzlmurj4Ur7Z3MVCx04V/
         XZkEMqDeY8uT1l/YnM82QqZIRuKbwbzLb81ZIRdTXIFOWwGOvoUNEOBI/XET/IrHk1B6
         9I5Q==
X-Google-Smtp-Source: AFSGD/XNCF/AELM92N+4p9/KZr4mLV4IU7b+ZllrdzFyHIFG9XuHFhwnCGsyXsvCDA2cnfQI83lO8g==
X-Received: by 2002:a62:11c7:: with SMTP id 68mr13037815pfr.21.1545657836303;
        Mon, 24 Dec 2018 05:23:56 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id b26sm71332999pfe.91.2018.12.24.05.23.54
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:23:55 -0800 (PST)
Date: Mon, 24 Dec 2018 18:57:52 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v5 8/9] xen/gntdev.c: Convert to use vm_insert_range
Message-ID: <20181224132751.GA22184@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132752.mXirdks5Pjoek46M5Ij5VQScrceAM9WAAtOFKKjDxc0@z>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/gntdev.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index b0b02a5..430d4cb 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 	int index = vma->vm_pgoff;
 	int count = vma_pages(vma);
 	struct gntdev_grant_map *map;
-	int i, err = -EINVAL;
+	int err = -EINVAL;
 
 	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 		goto out_put_map;
 
 	if (!use_ptemod) {
-		for (i = 0; i < count; i++) {
-			err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
-				map->pages[i]);
-			if (err)
-				goto out_put_map;
-		}
+		err = vm_insert_range(vma, vma->vm_start, map->pages, count);
+		if (err)
+			goto out_put_map;
 	} else {
 #ifdef CONFIG_X86
 		/*
-- 
1.9.1

