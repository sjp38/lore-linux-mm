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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4015C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:09:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62379218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:09:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mU6lU6IJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62379218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE9018E0002; Wed, 30 Jan 2019 22:09:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96C48E0001; Wed, 30 Jan 2019 22:09:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86708E0002; Wed, 30 Jan 2019 22:09:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9018F8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:09:54 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id t10so1299751plo.13
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:09:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=+gTPMCxXNjJoF0/n+ZWKrD0/ywZQWm6nRUnBrn1+xaM=;
        b=WBfrv5iQtQ2rfnfIWu4ZMkkl3Jg8LjSYzbeZ3p0ey4P7BmfF6hUJY3y4lFePvt1XH3
         83Q5WDuRtjwClmWwg68ZJDrKmbCvb2M6QHJWdP/U3T74UlpSsGnOYkoEfhMCxD0Wx1F8
         OprzUymIoI7DSZkZz/8dCmI7qMvdvgh5kLpNGn5FEPYvTs6JYJ7137Rb/ZHm6jnbyzm6
         IyHItEe70AuK7rGk3iqp1DAClY6mIBBleMkm76lvjrPGurrEWBRhAqYNWyifFIcWr3Rh
         TkhYKYNqSclFIVNl/UvUSb8/SARjneZeKxDiyXnAxHTpqaXVuNx/VyQ7yVpwhfopwCL8
         vzJg==
X-Gm-Message-State: AJcUukdQzEU5YMJuXvjG/K1Haki86knCSzgSpx8Z9cevIoHq9mfRiusV
	ObQ95i3Rz5iLrfGtCQdDxYktNVxOB0JXKjFV/INicsZmYsm38q17ZrkGmDdVeWmJ6b8nSCGnuwX
	o3qWcdUk8PO9LmaMin3YuSvnZrSYS0HW+kFFJcAJHabdrWbe/tPw5KxvMItge6Y2gp6/dbKCpcV
	mvsigtnXCY7mgLfUFfZlsZonaoFQMcyF0DCX3oUUcVQcxcTxTv2wUZTZJYb1Qf8mq1mHsCz+FQX
	dXcVCqiycCBXODioMux/AagtT9G5oysfiYghshEqvmiw6f8yqP6fXDiJjd0X8kQYtGrPILZ0TKd
	GkeUUoyDJGRp9fzmxohs4jb3SUjj9k2uD5fwx+dzLU73V0egMzlou6zmS/s04IspS8U/BNiFAjO
	M
X-Received: by 2002:a17:902:5a86:: with SMTP id r6mr31912663pli.301.1548904194212;
        Wed, 30 Jan 2019 19:09:54 -0800 (PST)
X-Received: by 2002:a17:902:5a86:: with SMTP id r6mr31912631pli.301.1548904193576;
        Wed, 30 Jan 2019 19:09:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548904193; cv=none;
        d=google.com; s=arc-20160816;
        b=AnUn71jINo3lblxBh5v8KRTxfFCPGt2m1Qi/c1B2FJKQHluPogLqZomG3YN5KkKHSP
         qNpPJlB5v/qix3ZWrwwVaLjtlt5+IpJy1u/T37Clk4f2WvOFKxI1NsEr99+Y9sHl9vaY
         pztiaiwfcth/3KXDFV8Hj6Cue56q4B0L2bPQigkuHgcPKGtm79JIqZp0dC/PgvHHeync
         dKq9bAhPeup1umD+u/g4cW2wP+BOhLizgZ5VJ+LuVGkyQdUVsxP5pOeXKYTh/+uqcSYd
         guirNlntrjZBw4sZEUPaUmzpznrItdVSvkjMofZVKdVi3ENYEHx6BF+qqG+CZc4Zl9Kd
         rqfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=+gTPMCxXNjJoF0/n+ZWKrD0/ywZQWm6nRUnBrn1+xaM=;
        b=vge0cmYycjGGbKG0gurxXlaeHJdEbrc1qNyopisTgDUsH/ODVH0unTQhe2s+AoPsJL
         WreCQEOp8rCWES5YxPrNsbeA53HDzYZk/BtbTry9DVBRYSTZNDhaTWXsNMKg4iqaGavt
         NZOaCviJ8s5PgURREIF9Udke73+ulQ4cHSe2jq9aqje1B30w8UsRcISQixrCeU/rsSOs
         rYc1M/Nn/ZCaExFgSNFrBiu14Gf9ce63dIGmxr7Of/kimaO98oDNTLuWKMDqdw+CUmdY
         wLy8mbKIFoyc8CfSt+OMGbXhKejzBPrXdLGHntjCZ8NcNHU57ZCKFq2H5fYaIxZ9i7DG
         SU+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mU6lU6IJ;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u69sor4938463pgd.63.2019.01.30.19.09.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:09:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mU6lU6IJ;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=+gTPMCxXNjJoF0/n+ZWKrD0/ywZQWm6nRUnBrn1+xaM=;
        b=mU6lU6IJNCLpuAcuJxrPEZ1u3GAeO+o0KiIBw8WOJ7nHkvQ/IRblpfpIe7nKGE7SRS
         Jg/T/3v0UNJFS2ktWc5+OgfeOuKABQn/qSDh9+tKHK1j6397KBeQm3i1CVZMMARZoL3u
         B6B8kBVJCO7f7uHnWzxHim/3AfChVmfnNtnvesAqnmMkFkGOnxIO+M8Df5usoBeDldYE
         g5trqSbU9wGgzK5DmVX9Twt/Nu/aUuItzZvMs4icY7h8Xm9U4Ns30dICFjWvsRwcLg0j
         PCwe83KHpSqzmkWOFkQH0lWMijXrL5IVqPElMGZbADLzAoDuWK5KCHbF4SBiqNu0V2H8
         0VGQ==
X-Google-Smtp-Source: ALg8bN6YIgFd5TO8T3mweJGXLOhL/Ot0Mn0pImW/qnzib4a+Il1p86aJ+miihranjEIIU0R7Kc0BbQ==
X-Received: by 2002:a63:6b05:: with SMTP id g5mr29145840pgc.15.1548904192746;
        Wed, 30 Jan 2019 19:09:52 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id 5sm8349874pfz.149.2019.01.30.19.09.51
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:09:51 -0800 (PST)
Date: Thu, 31 Jan 2019 08:44:05 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCHv2 8/9] xen/gntdev.c: Convert to use vm_insert_range
Message-ID: <20190131031405.GA2418@jordon-HP-15-Notebook-PC>
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

map->count is passed to vm_insert_range and internal API
verify map->count against count ( count = vma_pages(vma))
for page array boundary overrun. With this count is not
needed inside gntdev_mmap() and it could be replaced with
vma_pages(vma).

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/gntdev.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 5efc5ee..a930309 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1082,18 +1082,17 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 {
 	struct gntdev_priv *priv = flip->private_data;
 	int index = vma->vm_pgoff;
-	int count = vma_pages(vma);
 	struct gntdev_grant_map *map;
-	int i, err = -EINVAL;
+	int err = -EINVAL;
 
 	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
 
 	pr_debug("map %d+%d at %lx (pgoff %lx)\n",
-			index, count, vma->vm_start, vma->vm_pgoff);
+			index, vma_pages(vma), vma->vm_start, vma->vm_pgoff);
 
 	mutex_lock(&priv->lock);
-	map = gntdev_find_map_index(priv, index, count);
+	map = gntdev_find_map_index(priv, index, vma_pages(vma));
 	if (!map)
 		goto unlock_out;
 	if (use_ptemod && map->vma)
@@ -1145,12 +1144,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 		goto out_put_map;
 
 	if (!use_ptemod) {
-		for (i = 0; i < count; i++) {
-			err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
-				map->pages[i]);
-			if (err)
-				goto out_put_map;
-		}
+		err = vm_insert_range(vma, map->pages, map->count);
+		if (err)
+			goto out_put_map;
 	} else {
 #ifdef CONFIG_X86
 		/*
-- 
1.9.1

