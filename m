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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A102C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:42:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 269502192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:42:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="foVgED8Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 269502192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEC7C8E0004; Thu, 14 Feb 2019 21:42:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71CA8E0001; Thu, 14 Feb 2019 21:42:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13288E0004; Thu, 14 Feb 2019 21:42:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68D6C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:42:05 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 59so5788091plc.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:42:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=Ffm9ULQ6h9rWR8LY3P/l/L2jmZnHZP90ilNhPf0R6oHcUv8LbcbYO0GZOnInjWUmob
         yDc8eFiwdYhKf/YaP81hsAQbk9+rWG4E4l+NMdQhAQy2DfMR/Q7Ux6MYWIklMLpRWx81
         Bwaw22zFAtfTFTYzg2j2LYHIR62L15ek39C25iN+V+TIGE8F4Sb/liF4LDb9li4JFByS
         qu29qDWHTjCKuEyGiZQ/fr7YZS1IPZjoegZ9BSWgXv4KEfeyUOCbeBrpEqvBq4Zji8Hn
         c5KPYBQBEmRmZXQp8bhfpCXbyZOpD4qtIuw8BqXRAEXErGTkJ+ugqPSTns+8PElSQLJr
         79CA==
X-Gm-Message-State: AHQUAubc83lGfkm0avaSRmZwQV/vYrleXRec0wFkzBvehdgfJgjflq56
	QP5Ow1PhBVxNbMf1DmmOJlU3pBut1WYMp5OGluPZA8MfR0V2AJdlGfvYxvPBK1CuEs7iRWnXCkG
	rZOkq8r10yFje4rRINA1Y8Ar/hVBIYrNIXfO0OVeKKCLrbO9zzbgmw4syIAKLwexklJ+21NnW7j
	70i8Wswq7/E75amDFU0I6HMJfSPFAzGn0q/7+dfv6HzrD7XS3OylwUJ6NE+6BX8LGXvyYxSjNWp
	Qw5Kz7Ihb/fMlQiCrTCnDaKFTXMy4sst6IJbWFdpG5jmEYbS+cc8NfPk4H/P7eYzqdvU8rwyJVB
	gTGhp54f2mwSQjrc6Zwd7907c1JRkEnvbPnxsUmRtN1O+WA8g2oyS/7ncTOERVdCWpRVCkdmhRR
	u
X-Received: by 2002:aa7:8c97:: with SMTP id p23mr7585349pfd.229.1550198525100;
        Thu, 14 Feb 2019 18:42:05 -0800 (PST)
X-Received: by 2002:aa7:8c97:: with SMTP id p23mr7585307pfd.229.1550198524420;
        Thu, 14 Feb 2019 18:42:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198524; cv=none;
        d=google.com; s=arc-20160816;
        b=aWhPmOzVsSFNkEIixyysNMDq+wroumjNdMw568UAtExng2W1O8ChWQgvgYHS2eM9+0
         a1XcicxRET3ELt7PXXzRTknvNEleWAnfOL8oxO2od9LRv9+0T+mp3YLc75iYmS3Ldujb
         aIAVSgqEN95B+ROXgd58BAG1TiPoK6HKZXoohDhq15FMGKFtfnAIkTg+2dxBP+BhXSth
         5d6XumxVFraBb+j7tNfARfej7229TLPNVJfBB0gSd9J2iiusJHZ7hax62oyMM9osozyo
         ApAmdXndlYt1zZnsfDzqZJoHMz41v7lLXu9H93PX3p6HEtD75PXU1VlNT7GkzM/lgaa/
         GSfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=j3Ud8gKXPRe6JEDO1gmjPaSNecToMN0/AKTUQyPkZ2ALMJS6VtkZLwKfD4wedDh0h2
         v+y1jDvp8OIeiHmg7siy04pMjnYJFpT5MjzVJV4OoTnF4F72NbsuTCzHek/oBB5Q5XMg
         rYd5DNjXcZNL0D0yhVoOegs3HH1UkMlkslT1gQmGfLxSD3z9AyFtBfgR/B1tTwaY3xWl
         v9MpeS+2t8CFjUXQVkpPgTAumKWSqaxtZo+h1Ce34PKo8OEU5JOunXCtL1/Z1XarVo0p
         8b5/twnAoj+qz535suheePPnpfnH4n7MHpL2i4A/uwqLXe+lLiYT4no5CxISR8UeS/2s
         WnFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=foVgED8Y;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor5702823pfe.25.2019.02.14.18.42.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:42:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=foVgED8Y;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=foVgED8YU33cGUdNyMsYu1taL/xGldIA8jDJx5x9y9I6QigtUvC602CKjwOr0ZsAS/
         PrLVwNvSCYqqXgJkNNgsj/JW4o6PWnnMVV+sOZHXGFsGHwcW805LK+wgOzI/x/OVBO8m
         OE0NJpOQoDOheB7ogbrxz4yXHYX8Q4ORkgGb4p4hR8jDn2jxBGx513wY4g/BSbtUttC0
         +EUbqxPKWKxaEIwFfueP5dYGJ5wiFaiaVgytXN65xCDqGoDPEgYzQajnm8GLjMI6x6lJ
         uIsXrJrh4nv4qyfZmh7llHMdCo3NwZqLV9pBFVPB3QNi9ryMrkqN29sj6ImJovEthc7N
         Txrw==
X-Google-Smtp-Source: AHgI3IY09of71qEdGWmLQ9N0pTJcuq75/YFXp32CyRWU1WZj24MjvjzhxprXcBsoC8HhuoJWLmu0dQ==
X-Received: by 2002:a62:2e03:: with SMTP id u3mr2225821pfu.257.1550198524099;
        Thu, 14 Feb 2019 18:42:04 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id k19sm2131657pfi.126.2019.02.14.18.42.02
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:42:03 -0800 (PST)
Date: Fri, 15 Feb 2019 08:16:24 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	oleksandr_andrushchenko@epam.com, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org
Subject: [PATCH v4 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_map_pages()
Message-ID: <20190215024624.GA26425@jordon-HP-15-Notebook-PC>
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

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
---
 drivers/gpu/drm/xen/xen_drm_front_gem.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
index 28bc501..dd0602d 100644
--- a/drivers/gpu/drm/xen/xen_drm_front_gem.c
+++ b/drivers/gpu/drm/xen/xen_drm_front_gem.c
@@ -224,8 +224,7 @@ struct drm_gem_object *
 static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 			struct vm_area_struct *vma)
 {
-	unsigned long addr = vma->vm_start;
-	int i;
+	int ret;
 
 	/*
 	 * clear the VM_PFNMAP flag that was set by drm_gem_mmap(), and set the
@@ -246,18 +245,11 @@ static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 	 * FIXME: as we insert all the pages now then no .fault handler must
 	 * be called, so don't provide one
 	 */
-	for (i = 0; i < xen_obj->num_pages; i++) {
-		int ret;
-
-		ret = vm_insert_page(vma, addr, xen_obj->pages[i]);
-		if (ret < 0) {
-			DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
-			return ret;
-		}
+	ret = vm_map_pages(vma, xen_obj->pages, xen_obj->num_pages);
+	if (ret < 0)
+		DRM_ERROR("Failed to map pages into vma: %d\n", ret);
 
-		addr += PAGE_SIZE;
-	}
-	return 0;
+	return ret;
 }
 
 int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
-- 
1.9.1

