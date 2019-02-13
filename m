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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90858C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C92C20836
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:01:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a3NB43+T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C92C20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2BD18E0003; Wed, 13 Feb 2019 09:01:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDB8A8E0001; Wed, 13 Feb 2019 09:01:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF16D8E0003; Wed, 13 Feb 2019 09:01:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 903698E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:01:03 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a26so1929328pff.15
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:01:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=uZC5aAFXC3RSBzBneQzUfezvhPJ0Efi5+OvDp2RRuWIMwF0CAEXbc2/KODhLY1A2//
         00Ttta51cWcsqVbdIa50Cg6jG2UcscRTCzyUP9izg09GXCsE5889crM5e0GQXLX/6u2E
         u28mqAK+7W0l2fzGGJL+5UKHX8bB6CacggnwMCScxB8zJJlAEHS8vyfpp+fZJRQYbZ0U
         U0kuK1aY4jF/n8/VyEaochLQwxv1IoVaHP3bZ/rdpFyS2+cIfLCWA7eEI7KI7W664qwq
         JudqpEu/8WC2Js3XXBtQIH5hlhg1k6inIY70dxr9QACWVjYR3+aykekXt9CvNFqb17Tr
         rdmw==
X-Gm-Message-State: AHQUAuayLL5mP2RjzxHCNbzlU9b0SMfvMVMVAfInBS+xyoXgw/IrFpab
	qGsUvXE5mYKx9jcYZrfosImhWwLlEFmcSRSw/nv5WTwj5EfoIdGzih6eX6UfpZ4YYRNWJ5Sg7V+
	TVxW3LAwpYVwd02qgbt2l4VsBEF0ld1HVdl3JwXkddRMGec3fY/rmugnU8fwrQU5hr1HNxJCJnk
	I+oX0ZDKLP3g+j9hQaZFJpmMOoub/zifnxXsXmoc/RI/2qKnPeya2yLTEywdqKds2JQJm+pFKqE
	KKTDSYorhxjtHZMJv6VnaY/9bX3aedcm7fdcvwuYW1cb2my3u/XmYMyrC1qgiEcwp+cwyXzkZxc
	hn4B9KszljtfH191fZ1mTW+MoDIjISuwexEuSob9rV6IcZ8kALB/qguKcYIaYEkO3b8PqW63eUg
	g
X-Received: by 2002:a17:902:2a0a:: with SMTP id i10mr625174plb.323.1550066463260;
        Wed, 13 Feb 2019 06:01:03 -0800 (PST)
X-Received: by 2002:a17:902:2a0a:: with SMTP id i10mr625102plb.323.1550066462456;
        Wed, 13 Feb 2019 06:01:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066462; cv=none;
        d=google.com; s=arc-20160816;
        b=FoEiO+y6XqZCz2TdCg+0uDQa1IXuNpfz/XqZ1Aaua7aKQM985Etl9GuuRHS2eS5GDD
         LHsbhIrexfCGe16e3W8PwFjyLvdwL60EDjIGo9KJ2cwR8TKX6LdsrOcmfLCVAxL0ioZD
         k630tVoeB45m/zj9BB4Ws2g9AREcMg2gEKqecTLCS2B62LjBQzjNSYLXeFcmh2Sid613
         pnCch2gjUArOr8X0mcPJCC81SDUX8F8OyoCg4efOXcbAiACoTtoMogXbqpaoatLPxVIB
         4CM9Q4h9zrOVMyUkEVnepXfQnh+Rrw5I/6Ox++aAXb3+JDmrRzzk3B6vv0VjOM3O+kJQ
         xo/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=yCgWAHor43lzVKpXwMwONc0VtmJduEasvWkRB3KGqBM6iPHuvOzMBL4UTwhVEmbJgP
         IQmfPzoSoEHPonFLx/pBuxdBITTo5HELtsQLP5KE2PKyHW7uaq/Xb8qadJu60CkzvhLo
         X8TdN0s4L6M8+jkYpILmCG3eI0JVj07Sq8ICq8aGuEOsTSR9m515+wy3pADVG0QOVVEf
         URHjw5WtaDaN76E+Nqr/PCoy1+Y08TDxajc50dtzUUCLQN2yNS7Y/q7OMKi/acVK1x3N
         9HNzs3Zr4rZDxxwkSBEQSGR6OgRsYVf8wNgfYRZybayM+weth6OGoBnbXen2UbNcyyY0
         vWLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a3NB43+T;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l30sor23369199plg.17.2019.02.13.06.01.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:01:02 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a3NB43+T;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=a3NB43+TY8+WgWQevWmth0jDcxyBS/n2gAoDY2YZP49uixFVqF9mvLnqWGduB6Va/H
         feQh5HfmgXevrSsUjZhdngnb/naX2abIqktrI2KmmPQ8oNpgax5etRPOVTOOFtAOb1YG
         zhhHS9mNeuWvPEeHM5vcn+7gTBoWwJ0R+XoaM8QBfMA+CTM2NXjJVl6JImLxquz6l9Fl
         BtCPxnokINBzCCKtI+vM8SJ03eMGBK4CKngpr1xjCKL7zP2xXkcut5n3iNwAMAKrAb7P
         epNaoBisfUaCTj5Cg8+sPkYrY82yZ+MPAE/klZurmQjZ9YF6Q78A1sMJks+f4FhOgCiO
         J+WA==
X-Google-Smtp-Source: AHgI3Ibm0TTd/gAqweslKR095bYfBxZMG3ZrVdI1TDAsasHXYl9RczcsJBx08hZyBa/705vkTwMYUg==
X-Received: by 2002:a17:902:346:: with SMTP id 64mr650376pld.337.1550066462186;
        Wed, 13 Feb 2019 06:01:02 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id w65sm18734568pfb.23.2019.02.13.06.01.00
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 06:01:01 -0800 (PST)
Date: Wed, 13 Feb 2019 19:35:20 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	oleksandr_andrushchenko@epam.com, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org
Subject: [PATCH v3 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_map_pages()
Message-ID: <20190213140520.GA22029@jordon-HP-15-Notebook-PC>
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

