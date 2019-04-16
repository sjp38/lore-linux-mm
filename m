Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FEAEC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4409820870
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:48:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RlNJmhvP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4409820870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4CF96B026A; Tue, 16 Apr 2019 07:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFDAE6B0272; Tue, 16 Apr 2019 07:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BECBB6B0273; Tue, 16 Apr 2019 07:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 898356B026A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:48:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u2so12380509pgi.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=s7C2T5K2phazEDtTjMh/Wmb81vZ0Ls/PPCuUn7oOd3syynWy2Ke6v9SKLeP/6NDSGr
         MKkZZ2Kjdkm95ET7f0JFHxfBxLsvZ1ZZeuMcoM4/md74x7VyfS4Uuaw2/sah84q7RWjh
         H6c0oFH4SV+vXhMDYAYkxxz6TY/OsheJQ6rDRoVvHnmqRtmD94X8HMYmbvF2A0fQv1Hx
         GfVLKEEkVS7cF0GsgUzYz8FR0MC8GL0amVkErwcMGoJzrN5rT2oJ5IWkl/f3HYoYOKxa
         56lFHhdU5Nil/Jfdpcqr9IXmmVPpBrioqkxvH60BQeMHUU8rvGnu0RoqB6AAPBQz57qX
         KYwA==
X-Gm-Message-State: APjAAAXipDVb058uhFEmmpUCJP9ug3Cf3FkiSuDf8SPAU/JOm6iihgsI
	JBttA4hBDQRF5VI7ANMdLvm/PVO1HN8YbpbL3xMcnQ8r+0FJ3QON34bWUpIEw5p5x3ctgE8bwQt
	Pf999rY3yGN7WhDM5FqFLraUz+onElYD29IsMTqyrrsMb7T5VwupoHgInwouaQrQqKg==
X-Received: by 2002:a65:638f:: with SMTP id h15mr70217424pgv.147.1555415283247;
        Tue, 16 Apr 2019 04:48:03 -0700 (PDT)
X-Received: by 2002:a65:638f:: with SMTP id h15mr70217384pgv.147.1555415282564;
        Tue, 16 Apr 2019 04:48:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415282; cv=none;
        d=google.com; s=arc-20160816;
        b=brH/nmcZaGVAHr9CzQWMJNBh/y+tDqLGInxTnKYdiNp1MOqdTii0T0vCz+vB6UkQOa
         lLwa/PQbv+KoZymfWzkgznx04s+czg4Wlrs6zPB0TesPtFQ2serE7MBA9M2/HbGFGqDA
         jKSox/dIkTJkm3T6Xp/9jWJs3dTkK0UtLMx0jQsXawwjAkEmN+ffgeiqs5i2Iz1qvp/5
         vTLiNPB2ZedB5tKpGq3cOjfdajS3vDXd/5PQ7JpvPHIp5k/zp3EQSWUU9TkWjXbKcKGh
         GjTCFWp8eBXMglOh2lmmxVBssWallAQgy8eg/LjCCCLlsa9arEPS7Z1DMA8Dxf53XNy6
         Mmqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=a9Ok389DPy6+VJKnxaOyp0Se6/q29s1WreDdrtueqr4nKAf4mnqzgmZwI/eyL4vCOV
         KhSkxrmjR7a07BXIiGUhBOxzcpr2uWazaTCmTDijBb1HwxrlQQnfbfyxk0CmcGmvanRC
         YIAVChtEb4uIHwVWfbsO47HrljsUNwtyIc/8tnmZkNumHLoWBTK7MKM2wcMSIHbDkiFH
         jrKReNzx1hkix952yQDTYgnkgi7KukIjNG9nBHiKN1xfH91cNdWLqzL3C9RjRK6aMPo+
         AYDVsLgjDhIK6JAhLOjaKo1DYLBJlRA0xcBL5UtAotsNOAaKfqeF2ddHAcpalFgWqhSi
         jAkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RlNJmhvP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u69sor17913924pgd.37.2019.04.16.04.48.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:48:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RlNJmhvP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=RlNJmhvPVJ3UxKO1l98lIMDXQUnrSkDMLarOhFladUUf3Fd2LaDOG6+U01Z2z+YiG6
         sNYefT86LOIxnqlnmYbZyAcDruQYSCoLZfKjsI5qTBm4ikzvhilXTlPgz8vD0vD1p4zp
         nUgSswnCr91BRUTNAb6b5zyVdAQ+av7Sc02gJFy++x4EdGU7Ba+eVKI/tSv7RiqlDMKy
         SLqyqJH65OUoe0UtHrsN3h68RjIqxVfa3ycMpFEZs+Uo8eJrS3RcKM40edoCs9WmwoYn
         teADUMkiqANnatUpNqvAlG9eQwygGnntxE0k2iDAigCWgYcsyUHjVSZh8cAxSeXbIBT7
         1ERg==
X-Google-Smtp-Source: APXvYqx2gh4QQGIyXcsK611dByHpjpx+tKjskfqa9rV5hBQis2QAQtHs+h2xQ6nYUrNHQ3rVd4NVTA==
X-Received: by 2002:a63:f115:: with SMTP id f21mr70665089pgi.65.1555415282264;
        Tue, 16 Apr 2019 04:48:02 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.47.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:48:01 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	riel@surriel.com,
	sfr@canb.auug.org.au,
	rppt@linux.vnet.ibm.com,
	peterz@infradead.org,
	linux@armlinux.org.uk,
	robin.murphy@arm.com,
	iamjoonsoo.kim@lge.com,
	treding@nvidia.com,
	keescook@chromium.org,
	m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de,
	hjc@rock-chips.com,
	heiko@sntech.de,
	airlied@linux.ie,
	oleksandr_andrushchenko@epam.com,
	joro@8bytes.org,
	pawel@osciak.com,
	kyungmin.park@samsung.com,
	mchehab@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org,
	linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org,
	iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [REBASE PATCH v5 9/9] xen/privcmd-buf.c: Convert to use vm_map_pages_zero()
Date: Tue, 16 Apr 2019 17:19:50 +0530
Message-Id:
 <acf678e81d554d01a9b590716ac0ccbdcdf71c25.1552921225.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190416114950.27EV10zNOmxrG49iU1u3MZSkIex259DFj5dCqzRt6ew@z>

Convert to use vm_map_pages_zero() to map range of kernel
memory to user vma.

This driver has ignored vm_pgoff. We could later "fix" these drivers
to behave according to the normal vm_pgoff offsetting simply by
removing the _zero suffix on the function name and if that causes
regressions, it gives us an easy way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/privcmd-buf.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
index de01a6d..d02dc43 100644
--- a/drivers/xen/privcmd-buf.c
+++ b/drivers/xen/privcmd-buf.c
@@ -166,12 +166,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
 	if (vma_priv->n_pages != count)
 		ret = -ENOMEM;
 	else
-		for (i = 0; i < vma_priv->n_pages; i++) {
-			ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
-					     vma_priv->pages[i]);
-			if (ret)
-				break;
-		}
+		ret = vm_map_pages_zero(vma, vma_priv->pages,
+						vma_priv->n_pages);
 
 	if (ret)
 		privcmd_buf_vmapriv_free(vma_priv);
-- 
1.9.1

