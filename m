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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 755D4C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33FDB218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:10:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NswK+pXy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33FDB218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D881F8E0003; Wed, 30 Jan 2019 22:10:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D105D8E0001; Wed, 30 Jan 2019 22:10:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B89DB8E0003; Wed, 30 Jan 2019 22:10:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE728E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:10:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b24so1300441pls.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:10:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=iIOMyeYWlqivChsy2LGI2papAkfM6upHHEb8AWJyE+Q=;
        b=szSGMPtfzS55+aWTccuohxMaErS7wudNDK1kLNPSHC0XNJAfdpc/dONt4i3OPIETZo
         qxQrRTTVY2juZ4xaAvvXOVdIfPehRwO8wffLX1gRDMLXeG9+Ggxuxf+jrT9RG0UBFh9f
         1iSIWNFOp6r6eoVfubmC3SKykRoaPl80R2J0S5t+Fnb/QWfg9zfTyVVs9gTSB7pFf0N2
         FPAl21N6e82epGbDajADFEDEJHVE1dnyekQfekSioZIobsvTe9PVUfHd1BEaBk74N4BV
         roN1RvwxTjlK10xNv2NcyqSN5pS4hbwKyXnCPeqKGgR1chhMYpyQuQLcxtuycTHmfZqf
         nyTg==
X-Gm-Message-State: AJcUukeKMWhI30H+tp0uog23CSScGSsoDfKPkwxBuJLp9E5Ug+k73Xgt
	uHVLZAdDlzgdU8nhEYEXgs2GeKvaOBud/K+XahIEawTMp+qZl/o5G4uZXYriTXnMlsTlOzODW97
	raRSr+JEtCHYEIe/ENXaJyHsy8Af/+gRvscl90dg9So3p2joyyNVEHZmCEqc7mR75ia/SdpEfz0
	G5TkP9uQSRtagpPfALGOx6vueAms7jS1kAt5k4qVf4OnXVdA8AfLbICkpgkW/AmROYKTJfMeb+q
	7bZZpakF1gASlqPu1DX1z/kZSF5K76tGWbyLFWJ+Wl+Y3jxp6c+Tu9dcqqTXCc/8X3zIavgeYeY
	uK6y1wkQiP/vN6i+d86Bn6iF9p4pHwhNuWW7lsC0wm0QCIUXk2vJITMgXr2GyrMRNRI/5MRu0QL
	O
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr33590199plb.107.1548904241116;
        Wed, 30 Jan 2019 19:10:41 -0800 (PST)
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr33590168plb.107.1548904240464;
        Wed, 30 Jan 2019 19:10:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548904240; cv=none;
        d=google.com; s=arc-20160816;
        b=moj2KM/Z5AbXnDRY2Ic5+ccvE3YM+g/Rr+KaGBEWQMnMtEgy1hTyMlb23vtxDetLm1
         wcHmwv5VK7Wdsy7inr5cK3FZ6boql5TsimRK3L42xNePe0depAuVhHJ9EcQJK/BmJzaw
         BwQ7izDXAgPcc5nUh/VUbm9uiOLPHjaE64dBWL/Pk6JDRHy5aUGfLrKH60Iy3+idEik1
         X2qw9pbYP9AHM3dMwXJnlVKbom+7HeklBEMc5K5wkU1e32ot0t8RxFYuoZtaQFIyzHeY
         F19pBYNsznLb+KH7BjZyIdZ/oKbj0p7qNjYfmGNbDwCnKP8kE10+61GjwVKRXnTUCMdp
         r3hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=iIOMyeYWlqivChsy2LGI2papAkfM6upHHEb8AWJyE+Q=;
        b=FcEEzICNiLAqrBnR3nYo4V7Jd2G0J0pFj/cAS1gI1+oxkjLKXtDjli5mYWwNV0rBgE
         LiIjFqY/qEKCdDD93DHMQV7FSz4dWz8O3w4JUWz/O8ajZE56eH8dyJty8CkfN1p9utAI
         gaZZGJeCI5ts09kwUD346qF3JkUX9orwBsC3bhLNaLSUeFkInZZYN4RRflZJ9yOhPdLP
         4qwAgOsmfrGrc0jLy5Nl32jYqOGYhuNjj4uSr24INcBCv4GhkwrNEh7PQ63A5QWcU//l
         9wwlAwRfyV3mTT9mZJNbMvwVT9pygKjYDUVOsaCFyCDfA5jwl4dpDTPuX8Sizses2/Qh
         z7eQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NswK+pXy;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor4978675plo.56.2019.01.30.19.10.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:10:40 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NswK+pXy;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=iIOMyeYWlqivChsy2LGI2papAkfM6upHHEb8AWJyE+Q=;
        b=NswK+pXyki9uV20jIt/KHa7HuTuS4V54Zl/q2CrjDYOjRi1VObkIq30U6glKytirnt
         0uFEr/8IylNweVdpe6nAdkmQlUPc799Ng9XtT9HQWQtcaLU0vx0CH9uUKToZ0dcHIRRz
         OFVjx5BG4zF32ejxpzEAhCQwoiiyqWhNOBnox42mca/EHqg56YYWJ57EMdY5Dk7uHoNG
         1HnE1nbkcSa83Nzgv6xfPIkaG/VWmkT2hfc6BC5eKGqTkwfTAf8pJ4CnIVedn5x6zrD5
         31z46YUAOPYiqGZEOMosBhObBe9Bewwh7SZJ7fyrkzS6ImMft7hMC24e0ZOxrrmU+AXX
         zaXg==
X-Google-Smtp-Source: ALg8bN7JWTDtmY7f0SD7kzOXbcjmQSyCFO1iAegZ9zKD6pwUOUT9KVciGd4lF1sfXawzVQ673btnEA==
X-Received: by 2002:a17:902:4503:: with SMTP id m3mr33506912pld.23.1548904239727;
        Wed, 30 Jan 2019 19:10:39 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id a65sm3802656pge.65.2019.01.30.19.10.38
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:10:38 -0800 (PST)
Date: Thu, 31 Jan 2019 08:44:52 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCHv2 9/9] xen/privcmd-buf.c: Convert to use vm_insert_range_buggy
Message-ID: <20190131031452.GA2442@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range_buggy() to map range of kernel
memory to user vma.

This driver has ignored vm_pgoff. We could later "fix" these drivers
to behave according to the normal vm_pgoff offsetting simply by
removing the _buggy suffix on the function name and if that causes
regressions, it gives us an easy way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/privcmd-buf.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
index de01a6d..a9d7e97 100644
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
+		ret = vm_insert_range_buggy(vma, vma_priv->pages,
+						vma_priv->n_pages);
 
 	if (ret)
 		privcmd_buf_vmapriv_free(vma_priv);
-- 
1.9.1

