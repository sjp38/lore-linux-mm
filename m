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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8619BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:44:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39D1D2192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:44:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vt8nidr0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39D1D2192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21408E0007; Thu, 14 Feb 2019 21:44:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD0D98E0001; Thu, 14 Feb 2019 21:44:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C99628E0007; Thu, 14 Feb 2019 21:44:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB598E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:44:12 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 2so5761627pgg.21
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:44:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=r1M6HFHMjY6nSjfNPcyHQ2OEXoS30L+hwwdfMT9pXvtMnzM7SgCK5Me/xTx6kRwkIt
         K+dG2CLYiuj7VKYX60X6dr7HVetGkE0TydDN7YTiYywMgf+vO/jFj7nJ5qAyfzDJs+Rh
         Z5+R6CcW03YUqnXquGuLSPQw2KE7fhnAOsLTe7Jg+oR73NQQ1t0eoRFlSS7twj1QvBy4
         8/pdR9KPaR4+YnKX/qC7ThGO2jN16Xun/xNPGP6LGSNvs2wwtMOgVG8dhXEiY+08d3O2
         e8sqkdiS9q7eLk3DCl5bwwN/GMnI/Iae1OWv8mxobhv/1RSSdcNSnqkNfux+IfWndwZT
         hgIA==
X-Gm-Message-State: AHQUAubE+RJsZcVFD/s0jnOQB5S7EY2lzlnTuHWrS6u7MMCWGTk8sbzz
	z6V+KIqeNgriIRL9bVzURHElvR8F8A9UGPS1akPGqKUFEquSu7/FsuiXjpeAoj6cZbttdPxtPj/
	w+fIqHi+zqTmb3oNqQ6EheSB/uiPpMscNmoWc3pYueDRULYl7AnqfC60vHJiuRTznBDZDS4rFZT
	WagxscL6Z42iA5qHPdg0kJImEGi3ROGNXwcFnSEJGo3OEN/lL+XkmIbXZa2bSOgUXe8r2qYDAWX
	fmWqoF2n+YrpQKxBIcfqoLzgSRLRDZ8vpNvxL+pLjL4i05JH5b4kgKodDiPlEY0nomSXmOIt2AV
	qFEo1H+TulXX9Xfo5+kI2PjZCe06by5UqjaXWV01SV6UVfMLUQ1yT17tBd8XUTWZKfmZ53zWIK+
	I
X-Received: by 2002:a17:902:20e2:: with SMTP id v31mr7738203plg.307.1550198652259;
        Thu, 14 Feb 2019 18:44:12 -0800 (PST)
X-Received: by 2002:a17:902:20e2:: with SMTP id v31mr7738163plg.307.1550198651628;
        Thu, 14 Feb 2019 18:44:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198651; cv=none;
        d=google.com; s=arc-20160816;
        b=lGjZqezCg4Hn3r19w/CSx3/WfX1HtzEImygpnk+FQRFkoUP/xEQoguvY0pXt7dXVEJ
         +OEMf7QNyuXTsD15c21TpKy4aJTNqF79GGvDZ73c7vheB3ZW3HzwYx0l3gcdEfZwIK/w
         m2SfasyH76WiLDn+My1pSKp59NqHZLSMNvcL+jeJiQPknxeOos+7d4WAlm3QT+EwJKvi
         JUQhl4frOXYOFpn6vCHKfR5AnS9qxpU6FxPMmJU2QusM/TDInAgO6BbeabJ3NNU5QOva
         morHhLTMUYGI0ocnpqvndnCQWlFCOyS48PVS4u6UQozK+cPmkoFvl3rC0u4dqAF5u9hW
         YLXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=D39r4K4UGKmjJCoxN9S+MsCrH6hQO+mU4yZZCKm1jV7ZaQCEPF2hvXlcD8rQuMChpD
         9VV+nMkyatBKvGBvbPwCYXioBJ5au6ubTBiPm2AEu6dvxTR14FaS0YKSflo/EyTEoxh7
         1KIqPIptHffQKwPauAb4RSGPMhZW/hkHUw7Y9FWOZ1AfmVD0MxcXni6qVvLwbFSzFCQJ
         dMDeKe4oGOccirfDwtrhIbRicg3CsRdpydUuyEIrGM1UEq5/jb5rQRAFuRpV91SFUL/0
         r9ix4hQ2lJXWJ3zNCSNUo1N1FGB1ShHrBntxFpM0EZ6OBQX7jiTt4mv4UA2UvZa7POMa
         Hvew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vt8nidr0;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13sor6390887pgr.56.2019.02.14.18.44.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:44:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vt8nidr0;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=Vt8nidr0rK41Os0HWq4+4aF062X7h4v6mHNSGJrNppzhNDwX047qRWP5LTYUmhuLuy
         Iqtt/oPfQUVesoOPfP5pR37mpT+P5HeBjY/N3FdmN8Wc13V9Ij1VlOFDdTG1KkCD9Y9h
         LQKENgYLW/iXqE4T1/ZrhykWcCV8gemdxOrir5XOiDFzPc11Wj4/BnVAjWyDbTbpt0ta
         VbW+K/iPDsPHPWxg6IhMue9P7ETAnU+10BQ5VBAg8a1B0RRapCC5H5wh6eFntrZbvsCk
         v7WtGBOaFUVs6JL1Q2xUIeJxfF53otn17DmHM7ufjAiDUwRCJGfexUeqg6ur38YrawW0
         RvyA==
X-Google-Smtp-Source: AHgI3Ibcl+fzq90jisjOqRBP1UVmKB22vuwt6jwUdH2scf6jctjGOQhzTZ2VTYmiKE7rY4uCtAp5vQ==
X-Received: by 2002:a65:5003:: with SMTP id f3mr3127549pgo.39.1550198650905;
        Thu, 14 Feb 2019 18:44:10 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id u8sm6577915pfl.16.2019.02.14.18.44.09
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:44:10 -0800 (PST)
Date: Fri, 15 Feb 2019 08:18:31 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v4 8/9] xen/gntdev.c: Convert to use vm_map_pages()
Message-ID: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
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

map->count is passed to vm_map_pages() and internal API
verify map->count against count ( count = vma_pages(vma))
for page array boundary overrun condition.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/gntdev.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 5efc5ee..5d64262 100644
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
+		err = vm_map_pages(vma, map->pages, map->count);
+		if (err)
+			goto out_put_map;
 	} else {
 #ifdef CONFIG_X86
 		/*
-- 
1.9.1

