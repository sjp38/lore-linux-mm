Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62DB0C43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:39:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E65A20B7C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:39:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zv7k+Cak"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E65A20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87F3F6B0003; Fri, 26 Apr 2019 21:39:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8307D6B0005; Fri, 26 Apr 2019 21:39:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 745026B0006; Fri, 26 Apr 2019 21:39:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6776B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:39:52 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g1so1829952plq.10
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:39:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EP6WW3y+zSSixs0SggyJhgX6Fr7XZs0jbTOCa1+zd3Q=;
        b=ZaaxTZgNuE94vjq8WlbN8rcpSiLJhh1A8wAZawLdfcsS/tkYpRtUiwtyLWAFW5sIef
         24MGkZRrrT10Ax00qpvyO/cypnJMETSC4Pc31KQXDumgWqWuPY4hfihMlzn1tZBssPZR
         rzlRcpXoUKe4NA9g1gk2/ydJMuBYZOClal3XpNcvPHfIQPJ2M7/TO/6sNdh1+PeL+bkQ
         AOVTqlBGheEI4fOPIaBia/0FvWgml86F5Us9s051kqipRGwZtSX+GQ8+Yniwqrcy9qbQ
         49SOmlGAT7xemqqiq02gfLz+6bsqgG/m59LNmbiTV2swngvxQu1+6oBzMl2JhhwWUN9J
         OUvA==
X-Gm-Message-State: APjAAAWo0gUN6I0S7tiM6thloOVdlc7L+s14dtSa8dhLI3Cj8dZXu+vG
	0ejk2CAZOXsUUjgonYYw+9Ahv+TXEimGgnoewN8r6uMUlJVkdQwekJxUv4HkQezvgoFvpAzcGEa
	/TWT5uiMngyl7IuZw4oAmC0HkedH8i7qJF740tBVLtE1GInhuPg71Ab6VJ+tCqzPifg==
X-Received: by 2002:a63:1048:: with SMTP id 8mr46450448pgq.70.1556329191319;
        Fri, 26 Apr 2019 18:39:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxB7AC75cP5HewBo4UTn3NfCr2hQnXh/bMGXlUL4LgU49y9ZkpicDMohcvAd/CDgxuecCsk
X-Received: by 2002:a63:1048:: with SMTP id 8mr46450404pgq.70.1556329190479;
        Fri, 26 Apr 2019 18:39:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329190; cv=none;
        d=google.com; s=arc-20160816;
        b=NGw5bseldAaEKXir+Ck10bO6IHUXSmFTUafff23N2I+skz3lgj+KJLHySbXq1C7r7L
         Q69W9zA+5olS8aEFyQSCXO1QJfNQVUOP7RKJpmU2ZcrPn8erD/2qj4R8o04WaXduReao
         lN5oQCxgR/4AceYHQvseSdleCWB3wcWwN5AbNf77aoYv5jIR+IyDwvSqHcg8GPed40xZ
         U9AZ2jOATGx51oyjLUa7C8/Q3z33Z61OIYsgqAFMfApXfcgE7qEnT7rGGGu3azFTfo2b
         p+BslbidRDwnvREjcSemlzsXe8t2kQ/U9McOFmUSq+vKAdRw+7jwDo3jPJQZ3nJ8RGWh
         u5vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EP6WW3y+zSSixs0SggyJhgX6Fr7XZs0jbTOCa1+zd3Q=;
        b=mb2sFKaIs/wxTltgcajktiKyEkC9k+LYJc+P6qVKKf+/hyFc/u9/KoDOAq3yI4eNb/
         QJwpN6WT2DyD0FNENViILQqgGz/L9U+UW9srhivDIj75r5fYt96yrXADoSYaEME+CbR/
         K6EBzlblV0f6WeXR8x549BQZrOUgC8hks3YWfJ1c1KA2dS5o1Lut7st16hkKUoYPd0wc
         XoIl/rbphIzhTloJDvfudqaunF8/sjjTxMeQ3tXKqYkJaME1RbdbzuSsrSabe7/MTelq
         A4Q1o6aXev0D9Xx3vqOZrR7sawBTthM0OFb1AQvotX7WTs/j+61BXOecpyDUHsZbXdDO
         aG6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Zv7k+Cak;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f10si25241888pgv.589.2019.04.26.18.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:39:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Zv7k+Cak;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2E96D214C6;
	Sat, 27 Apr 2019 01:39:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329190;
	bh=+8vMyOsIN6KDliEj6S/eI4ORry4+Lma2T1on9iTX9ic=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Zv7k+CakCtN+1V/ICzC7I9GA99ebn1yPe67bW8uF8lexngXAfFimjIHINSNVO76Vz
	 HCBFOFHRba0/JqBF1qFjpMLQD+W/pQITtrqoTx9+VEMYrT7c0IX3Is++kaa8TZd56N
	 zRXSpA2GGds4c+rzde2WPPMIpBaDpK7knzdd5d5Q=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 45/79] slab: fix a crash by reading /proc/slab_allocators
Date: Fri, 26 Apr 2019 21:38:04 -0400
Message-Id: <20190427013838.6596-45-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427013838.6596-1-sashal@kernel.org>
References: <20190427013838.6596-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit fcf88917dd435c6a4cb2830cb086ee58605a1d85 ]

The commit 510ded33e075 ("slab: implement slab_root_caches list")
changes the name of the list node within "struct kmem_cache" from "list"
to "root_caches_node", but leaks_show() still use the "list" which
causes a crash when reading /proc/slab_allocators.

You need to have CONFIG_SLAB=y and CONFIG_MEMCG=y to see the problem,
because without MEMCG all slab caches are root caches, and the "list"
node happens to be the right one.

Fixes: 510ded33e075 ("slab: implement slab_root_caches list")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Tobin C. Harding <tobin@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2f2aa8eaf7d9..188c4b65255d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4297,7 +4297,8 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 
 static int leaks_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
+	struct kmem_cache *cachep = list_entry(p, struct kmem_cache,
+					       root_caches_node);
 	struct page *page;
 	struct kmem_cache_node *n;
 	const char *name;
-- 
2.19.1

