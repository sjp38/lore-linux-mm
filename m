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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36A00C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E72E62192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:44:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QWuFZnGW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E72E62192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98D788E0003; Thu, 14 Feb 2019 21:44:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93BFB8E0001; Thu, 14 Feb 2019 21:44:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 805348E0003; Thu, 14 Feb 2019 21:44:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECE58E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:44:58 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so5789713pgb.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:44:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=c4jCjnggpvJu2W4XrUfdNqtC9bHH2L7eFZ36IP0T3zouDAEW9axsXvpsAGlc2YTSMG
         +Yvi2z/3rqdYUPuWn/2PzcJjYqLoAQ/GoNMf9mJFDNMiV++ZrDG4GF+MdeJbW6ruc3UJ
         txC+lRs/rmWvRRnXA1P/nX/qVT5dOz+5qbvvUuhs3Sqi7NyQqgLQWWa+9KuDPI3RREe1
         DfVbIDh/A1i0QWz0P+UDMbL+PJNT+5hD7TlFH4oOYdTlnuMyDt37a2Gaj26+XGro6YHd
         2Px2U7RbYTqOdjZtlk0iZgVlXjlMGHdEGV7uf3oNXas98uhL6O9WUCP88k8e9KoPifgK
         pw0A==
X-Gm-Message-State: AHQUAuZgPuA2YtiMm0SDbMWZeL5e5RohnbWlz5iH3S5qYCLMmr7m70yx
	2yv0vIU2fbrmFyNE7JMV+YExosq1nXyvKxTYRcTR/E6lKsR4AIkzJqT8ZwaRbX01opPwj9U0mr9
	A+BBb2a7LiY+IBT1ZRsl2VoTbbqqNjovVBpO7sfOERKyuePPRXiR1bhiLMjSO10wHh2/hr51VkY
	45pUslyAKvzmEDKCJ8UHKtJe97Tlj8l9NLBY0SCkmN0P+qyLTRA7M2kjK9QsA3pKahACL2QD6YH
	vFUjZl/pjPCEH2DUeQujMpqyR/Sxi1UrPRNjsYgyUwllvRgWxOeKT+MQJMJC7z5ZX8FPTjFk1OQ
	pebzNOQZITM0PzkVLXtnPAmFloRILw8SvvFu743VfuamTknW/kq9MDtp/RIvw9MMHZa+KmWRWYQ
	Z
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr7671662pla.177.1550198697937;
        Thu, 14 Feb 2019 18:44:57 -0800 (PST)
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr7671626pla.177.1550198697285;
        Thu, 14 Feb 2019 18:44:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198697; cv=none;
        d=google.com; s=arc-20160816;
        b=xaWa64B3IXEcOfk24ke/UHKZjbI1RnvfAImmOZ8m1z6PVw+28R8KN4Wa1si5nKW/sf
         nlS7lXXwDJrpHix40IQLORZdi8tCdUEDYC3b8DJzR8bQzOMmFYBpFwFH+VnjMGaRDiK4
         bXSUi6McsWRUm9A57aenaqgiN3aexJ+ferqu4L6G6GVIiaTZi5xdG0il0PwRKq6t8jGy
         x1XVx2PRsMYOJ16gejkEskpl9cLwTps3l0QJE4u+LqbTPY0WoHK4ns3Nc9aoHu1+Flr6
         t8HYiPY9oTPBiMPrLsH4K+ERvyH0i7GMV7c+ZkivD5YmcCAp3F0SnHG2wBGAJ5waKg8R
         9A1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=As9tFz/1l4KJBkM70eHNvPs+aJznmnSdB+DVIl+Bkpljz6r2BnFEAcUhunKorFPbPt
         ZUTBnHZc9yGN7KlYkzOjraKwUQCR0OiAY8BxZz7TvbPxu8OBEzikgaw6RhhGkqAjDjWY
         3A6YRhWC6/Y3cw5Wa4Fi/iZmcM0sNhw59qjtc3E9X7nuiRfSZYe0KNCS4no0UMcNeVPv
         sC3tnBJJ6x7jhWCqXbXBlGIQmawNiummfc0qaE5ALEW1+LtuqFxa0lShf7u2MrD+4xrV
         yWFqIWez1SrBGMc5VseUj/fK0fcBVRcgjaTIeqr0Sb9ni7uz5xKTkGTdHvHTPyaMCXiE
         tc1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QWuFZnGW;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor6401403pla.7.2019.02.14.18.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:44:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QWuFZnGW;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=QWuFZnGW1rAFmlIYTR8KT5WNdvrhaezr0i4ZoVMqFLa54ofNW2h9D9a5ZzgYyp41MF
         rvXlFdLTe1vJbS+yYGRhKQFGPj+MKLD1iVlvMm9nhnIlH0nFQ5/bX/r3BgdjW2MtktLL
         fE5F7PKlj7zIDHLD10ydW/9+vyhDv6wCFhmmc9esTga8VDt9eB/q3GWtNUJB7Ih4v8gF
         hysNnNr3phiGvpEKd6M8VkY5G2p4IwHVd8tz8sNvMG5Yof71tMkfCzELiIvS7ATGGdrk
         f2Fjtt+lYU6DRmN0pNS3UaeqrhCqlzqJPjrNKTGR5zpPj8DyL7JWfrs3Bxalf9n153ai
         kn/g==
X-Google-Smtp-Source: AHgI3IYS4Rmfmmn4KPKMZ+5sCz/9GuQcTZN8Ld6ccRNBZU9OLJommfG+bJc6qfgdLMUnSbD4C9x9Pw==
X-Received: by 2002:a17:902:b190:: with SMTP id s16mr7726474plr.262.1550198696592;
        Thu, 14 Feb 2019 18:44:56 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id t5sm6861584pfb.60.2019.02.14.18.44.55
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:44:55 -0800 (PST)
Date: Fri, 15 Feb 2019 08:19:16 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v4 9/9] xen/privcmd-buf.c: Convert to use vm_map_pages_zero()
Message-ID: <20190215024916.GA26495@jordon-HP-15-Notebook-PC>
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

