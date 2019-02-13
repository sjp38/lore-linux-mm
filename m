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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2291C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:03:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84E09222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:03:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mR1zb3ZE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84E09222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BD628E0003; Wed, 13 Feb 2019 09:03:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0458F8E0001; Wed, 13 Feb 2019 09:03:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E296F8E0003; Wed, 13 Feb 2019 09:03:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCE38E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:03:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so1917334pfi.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:03:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=nyt08jdY0K2UdNE4q5JvE+8HRGAN2/9ZYFp7lDFOmjk2XhEFBghGg9Fco4KBxoqJQq
         /7MaE74tqvX6IsfWvTzmi3OjN9QqTwF5dCHUIyrzbxp/GYgQ413VV3qB38ibo+LVPRCo
         FAwTnn5L9Csbynp32H4I5bnc3bF+uwsmyDpaqw9ue+ri2C/EabxQ86zGNZQvpqzBsIeP
         r8iVBAmWv8C9kE6OsVnsYfGel2eG0FdzmOD6ad48sd9s6sKyPv1EEEIz0X8cMt7nzEbZ
         Z9BgPqkSPKsyK7RqlpHHD8+IMVqorwXMUPutxjLEKK4FeaRQAwynZHVk8B1iwQYx9GXw
         34cw==
X-Gm-Message-State: AHQUAuaKS5Gmi9rq5L/3Lfbv/yotATNjW7q8tn5UJ5OejULtCd9VSCya
	7qB+9J9Q5GWKCyf7pQfd7ohLiIMF65+MqQiVl3h6pEOoCbgVCXeBiHeBjqzpdRNvSih/4v4NEvE
	oS6RVbDfcm45L9E0EEb5jjtTziTAi+2+/xBlYaXT/SmomSJ37fFqSZRJ2XU/68mv4f6FLvz7/+H
	vM8Ho49P3xuloRec/eBiKNVmJvBbBC4xqiP42da/WuPIxSnBbsvldpjhw/3/yDq7UwurTXS6h2N
	/wagcDMqVWSoFvmRQBGnVtq9kiZIU7QUX3CnIJrkL5pTD43F4bmi7+SQJ8uEdTlTGES+xr5ye1H
	9oGD37yfQG0MEqiUqJMnFH6RoDr7sWj9uoS/BT9M93i8DP+ETV0hyPfydtEvSxhGULw8mXftFF5
	7
X-Received: by 2002:a63:4913:: with SMTP id w19mr617531pga.394.1550066632293;
        Wed, 13 Feb 2019 06:03:52 -0800 (PST)
X-Received: by 2002:a63:4913:: with SMTP id w19mr617461pga.394.1550066631298;
        Wed, 13 Feb 2019 06:03:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066631; cv=none;
        d=google.com; s=arc-20160816;
        b=FZnzrJ9G3G9HF53M465WHQNbLYlCJwvr2CJ26AsVBREkTrKm7IZ5MFHHjwEwZyTiBc
         JS9W0TulZE05nNlgL3NdcNTFPmL2c3XLQIj69Po96CHowry5u4odAlook1KBX3yQP9w0
         oLlhQ6Iy054HOk2lrN+sLuno2rCtlgOCXtdHlDrzuoa5Sc7PPOqWgjymvbECwiAx6T/a
         zTg7wEGrAkRryq8RjFMP8mzKxHFLeaBJ0j4OVlmHuHAmWGui07m/s3NcU7cb/FOhBPAC
         64k0KwMKF856DB0zTXEtAujoL+R4gJxa5+RJGxSxfdq5FXWzU3pova1hg6RD5GEbqYq/
         qTHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=ak9NFKEQKGR9Xyx0igani5XgnjVTXB9HisGMybEShlUKzZwOxZyI3Ej+tOl3CuLQ55
         nky23ADah2ZuKnacEumM6TqqwVkoPZkADTyXtOHo4J68DJ1E72R9pRisFzJM/zE7MFcz
         DdtfPQ6hb6PwCg1wZxeF1EwrIK8XdDsHkFWIuUjT5+AXKasN69csQk0IPwwR2mhlmIYe
         fSo250LD8B33tDrpO+grdz9XNe3Scqg/8Njz4WPRD1TnwiNfgnH9KpJ3++4vlMLBCnKc
         XIB8dL+NTNKkN9Vk2p08KIckFgmPeOr1+5x9KwBd+0BNyu1gq0bvE/GCPy+TWUlDaEAj
         OIFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mR1zb3ZE;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6sor8959984pgn.60.2019.02.13.06.03.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:03:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mR1zb3ZE;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=mR1zb3ZEg02mBIPkYaAVMZE66k5L2R/4wFfthpIKD2x3RXESd7eiszAW4r1knRLpTn
         wnxSzM8wZc5Mkz3Z49kMS93pCVbrKDkebiXliRr0MLguCoBBzx3UIY6gRbVSevX8sUlA
         t0TnCvA4KzIxDQ1NhguOdXUGK6CEp2PM35M5kw6L8CUGCQorsyg8koIIUymChKedDxwo
         wDUw7vvME3QeIWVpILxu3BZjyCiOfgTp+xlM8wcQWb2ioU0gaK0lIdJ+zNZxg+bA9B1c
         6HYiTaKbvgyyQHIL08zPUp5Nm4UWICDz8npUj7KAUtwMGujiFlESyiR4EEVtAG0NSBzJ
         vYBw==
X-Google-Smtp-Source: AHgI3Ian//MU/KECqqeVW28HKO0eOqidmv+3nYdGVBdjjqesuGGlM5g1X58lilAYfu4GeuswRHCPdA==
X-Received: by 2002:a63:d444:: with SMTP id i4mr600550pgj.237.1550066630319;
        Wed, 13 Feb 2019 06:03:50 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id e2sm36513942pga.92.2019.02.13.06.03.48
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 06:03:49 -0800 (PST)
Date: Wed, 13 Feb 2019 19:38:07 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v3 9/9] xen/privcmd-buf.c: Convert to use vm_map_pages_zero()
Message-ID: <20190213140807.GA22098@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

