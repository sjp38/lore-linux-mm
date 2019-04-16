Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB6BEC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A05E720872
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G+5l6dnj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A05E720872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5128B6B026B; Tue, 16 Apr 2019 07:47:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C3056B0272; Tue, 16 Apr 2019 07:47:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B2A16B0273; Tue, 16 Apr 2019 07:47:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 021B46B026B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:47:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u78so13893158pfa.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:47:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=dpXv6tzWHkdnuJkh2eGcbQ3oo7eQTE+aTVlIl0q/Zatfx2vRpzu5yhq5jrU4JeBSYe
         fAVsOeyeNEz6fj3CI8fbVZYizlVEHGbddUGI+pRZqo8W3FJKezrU8bZq2lIcK/oytK6Y
         rSERgMJJE7uk3U2cJL//rzJSXV1kljuc0Tkr7ISOVNay9lWJqyLgJI5gWktXVlWpefTJ
         DiLdgiLvXTZ4cTxiq6tQ1tL9V6WehqsEpSjXovcDT614CAO4Mn7xElTmfKlTYuLEav/J
         KQc3c3gZ+RsGSrwbXtgV2WrYN3JsbpTpO5zbQ0EaxI8+9qmjqYW4uf+cJ3iudsFN7u61
         lNkQ==
X-Gm-Message-State: APjAAAVw9bLxkP3BwJhviXjAOZRbT+Zm9hIqeT0EJeagFJl124Fatux7
	3OOHBxLjX8uP7ZEcBUkK1ysQCSXEdMrATAXBVGi4PcjPF+RfY/RKJb8pNL5DoeW4dmSgSihENnr
	/2Ej8TwHFBVyneq3DqI2onxE761KfSyGS/mLpC4Pwu7wNByOpHq7ujYwxaY8RIppHpA==
X-Received: by 2002:a62:121c:: with SMTP id a28mr81384057pfj.58.1555415273707;
        Tue, 16 Apr 2019 04:47:53 -0700 (PDT)
X-Received: by 2002:a62:121c:: with SMTP id a28mr81384004pfj.58.1555415273025;
        Tue, 16 Apr 2019 04:47:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415273; cv=none;
        d=google.com; s=arc-20160816;
        b=gSPogXbc3NGTG5jFYB+SqBjrETujSbbspom8ewnQaEoE2WJHpWjob5qgiLZOuf9t6Y
         sT0DLr4uAjsysyDbNjumlAWLm6qmTzzamactyP2RGHzuFeTKDtROFCEZDa8SZBK52NUl
         IWQDT9YSHxD8eXTQ3mwp/XedexWkrGnDuCqoK5ekmr658JjI758TaD5gM4FvVrpBCMdu
         X1f1TNoHuYXkbRhsRs052oCY/zywetlqopdF338l5jWzzqavG74t64aoMdlqEfTx6sP3
         WhTOH5ByFLOsSgVE3UJb4d9h0lChpJWe1/v/f0NA5n6re66xaugAe9M3O/MxHCxxtZfx
         PMgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=SaVgxW+O/QdN5ax+V4GUS5iGpIa3t/TVuJGB2hHT8H0fdkSUSVr6PgLFQ2em2IDAtG
         ddcnt7MRrHgSzVDQRClpcO7K8MvtHlA4GIWHtiydzXNgi0a0suoUfw3jdKlJ/6zYTVvO
         OytqAthP+a0nuZfnUCB2m/PVY80I6OUAHvtyrRzw67uqWFe3p0Ix3GIC5u+bZdrMklyo
         Hxl0RajZqGG06gvhbAGImlVnpVyUFBbSOunPR85GjmEbhyKg+bWT/aCELBr/Osbnge97
         x69F6snZABPE2XU8Syu5QXf8heT9IMQMgtKTvO0d8Lh+VMpSVJLcwp/dnlvhbV90bQ8M
         py5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=G+5l6dnj;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor65833312pll.8.2019.04.16.04.47.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:47:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=G+5l6dnj;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=G+5l6dnjc7/uWHI49g5xNQ2VmQniZgrpDhtRlmcY+E3Z7ocVubcskS2MrTMRU9ZU1N
         L0ULzCh7L5KPDeVBbv3aI560DkAoMSHXT8dUm7C87hk2rUJYuZjB2G4yctoncZH8pt8T
         pH8fBdXKGlqeyQtXK33z7+r6JJdj8JD8M2WURaPvOg1JOtMj1vqV37D3kv/8KcRwNk9w
         o1d45pjV17t0tKE7c3wu7swo2BTkJ5qq3mPBKXgANsJyDy8TaZkptEOEnjJW3sUylrgB
         WWAIvs6OK4hoNr5DfAjomWAvTR66t3MVa9o0AY56ghuFufEyHnfQLWCwrELKiWG9EtlG
         4vhg==
X-Google-Smtp-Source: APXvYqz4waYiopA3l3q+r1qCFeqwSh3ZXJMr5uwqp8r036DYgcWkcY5QNT6ibdt+RI1A+3hXGE7RDg==
X-Received: by 2002:a17:902:b210:: with SMTP id t16mr76931088plr.84.1555415272752;
        Tue, 16 Apr 2019 04:47:52 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.47.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:47:51 -0700 (PDT)
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
Subject: [REBASE PATCH v5 8/9] xen/gntdev.c: Convert to use vm_map_pages()
Date: Tue, 16 Apr 2019 17:19:49 +0530
Message-Id:
 <88e56e82d2db98705c2d842e9c9806c00b366d67.1552921225.git.jrdr.linux@gmail.com>
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
Message-ID: <20190416114949.23ZzURlB__gJkeiSzcf3LotQQc1MEKQDKyIGVUFU_Pg@z>

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

