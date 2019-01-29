Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16689C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 05:38:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6CD52175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 05:38:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jDg0qNhQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6CD52175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B0198E0002; Tue, 29 Jan 2019 00:38:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5605F8E0001; Tue, 29 Jan 2019 00:38:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 475C28E0002; Tue, 29 Jan 2019 00:38:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 068258E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:38:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id f69so16008755pff.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 21:38:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=t8fkzWMHxXDIkytKtq4mCKfuJ+XlIbmSP26+VZ3R6Tw=;
        b=Sdq6cQ1+czaPjNWEnkl2rzmtOGOnqGa1dK6ZQqu+k5KFEEem6bhgngdHOhPs93lrFW
         DGwWLbQAHnirX6ASxRj5GzyvZ68JjX1yUtRn8GQO/+YYVcCv/O7IT2YwjpSW7tPsdlWv
         LozqiASf6ZjKNtD1S4gSGo2Gkp4Yx0LGNHP+mqLt9r+xGQo1puPCeXIyKiZmQjlrUCr8
         XVLJoJxbfj3ha42eMadrO2NQpGasc84VBu6Pk3TL/I6QSMwnFqRpIPyt+6LOAGrGKY1f
         h0lbfjPs9cqbQsi9oo7gQ4dC5q4/Nb00Vt1bKklFcMuGDluou7hCSNkWGknQ6b575HMn
         UtgA==
X-Gm-Message-State: AJcUukdTh4TyMNWP28UEBh2wz9WDAjCW6myfwZ/zngtE88udzWReMlhQ
	nCv+e3TvvekSz/BvlieLFddbIcAr14JIZe7STWhrcDB/gB1QRRPZb4S0Cw2k+dCgoBQPdYDNBlA
	1c4fuKPm1DcA/R1t5p9ObWtVv9UtnwHfehuX+ecE2YFBc6hTPE6IN7+1/1Nbg4wSa7w==
X-Received: by 2002:a62:868b:: with SMTP id x133mr26051215pfd.252.1548740315613;
        Mon, 28 Jan 2019 21:38:35 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4j3sjzw9fjDyAtV7PHz1xX34bK6cp68aWOW5YBb4ZAm4mLxflH/+Y/sD0iS+84hH0X/J6o
X-Received: by 2002:a62:868b:: with SMTP id x133mr26051182pfd.252.1548740314806;
        Mon, 28 Jan 2019 21:38:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548740314; cv=none;
        d=google.com; s=arc-20160816;
        b=ri9v3Thxxki/Z1nqYY26c5/A+bi56QHNiIt01SSopc/Y4rvkVgDx3v6CMRnNAL96XA
         Lb6CIk1McOMGYyKSaEfU5N/4uTe/BNE8G4PR6vCqDq39rfBMPyszVlsGU6kEFCTDX8bw
         vJCxJntZB1LtgSJxlXb89w4tyHlIQOS5qFv5lRwRkb3d9tF/9jtK4lCy8riW9tU+3e01
         R9/oRt9GhDX0z/l95rsbR3y7/aFRglZdpBKyo7Epri697t1P0dBpuOk9veZvoWQl6ANl
         9mheBEKMGegLkay1CliAL/eP7ntdd77sKwE3DdgT3mzcD1/zgE6eT049d+4UmrJh8bl9
         Yt2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=t8fkzWMHxXDIkytKtq4mCKfuJ+XlIbmSP26+VZ3R6Tw=;
        b=FIHRg52l1kRt27m0Pt4eht76AxbYIXcbMTw7fpDIY5cnk4/0xMSDxKqZ0/hU3R4NBl
         hd9/kd8rVNjaPL4DHs+gR4lfdZ4kFwQPhOwhOJkgFBDdvZXtP+EHX3x3akfHeMViXuiH
         3H/bF9vG0U2UKbEFWaYZdokwlhlzvizmFYFbworizEFxnjEqZAKoguZSAks2xSVNnC8q
         rJxnd66SRFkBcgZop7j8kIWEPLIT7A2/B7zmWkt2DWh5hEkP6Z11B4i28JXMR0hN5Dzp
         a0m8y/mlp48NuLlPMcTWI/Jqarayg/NrOOMQAFTyiZay76uZHALwFtJACo6zP6NKXW1i
         ftxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jDg0qNhQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d14si31553429pgi.158.2019.01.28.21.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 21:38:34 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jDg0qNhQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Message-Id:Date:Subject:Cc:To:From:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=t8fkzWMHxXDIkytKtq4mCKfuJ+XlIbmSP26+VZ3R6Tw=; b=jDg0qNhQ8VD/4F9eDb3TAcCXx
	KgrHXFD4VUcQ7FG4aqXzx+03Sz9cGxs8Fu1XTbjulAd4M9G9ltw8J72wpUM4eG8/t3t26w6TYpkZ+
	9j0Di4upLo9PJrngncDKQ60gYIFuZITAk1kfiOHP6UwoEHolJKTbn3p4iK2STBQpOh+bhac4NIyhr
	Srd2fjPNNoh/yaxeszJy1KPd41ffdRnUZ0VEWvUHxnsiAkVS2CI2HQaqK+6A9DdWP0pGCsjSU1rkA
	wuDjExz/IA8gHWwZ0TjoqfdZ7sVZ1TM3TjwAyCAaSW2NrFESAE5jqaGaCohDGut/W01IpjUZFZdZz
	W3aRK/IkA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1goM6T-0000zO-1P; Tue, 29 Jan 2019 05:38:33 +0000
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	Kees Cook <keescook@chromium.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH] mm: Prevent mapping typed pages to userspace
Date: Mon, 28 Jan 2019 21:38:30 -0800
Message-Id: <20190129053830.3749-1-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Pages which use page_type must never be mapped to userspace as it would
destroy their page type.  Add an explicit check for this instead of
assuming that kernel drivers always get this right.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index ce8c90b752be..db3534bbd652 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	retval = -EINVAL;
-	if (PageAnon(page) || PageSlab(page))
+	if (PageAnon(page) || PageSlab(page) || page_has_type(page))
 		goto out;
 	retval = -ENOMEM;
 	flush_dcache_page(page);
-- 
2.20.1

