Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A26C7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:44:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 557FC2146E
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:44:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vNuDOMtk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 557FC2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0631C8E0006; Fri, 15 Feb 2019 17:44:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 012978E0001; Fri, 15 Feb 2019 17:44:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E432F8E0006; Fri, 15 Feb 2019 17:44:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2BC08E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:44:14 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a5so5317406pfn.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:44:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fS5mmi3aRfTJ9ZPKh6Kon1+z1mp8jA2r8sJju4C3jM0=;
        b=IaPcpwqgCE8uupm0FptSImp21pzAPwHzrkwtL8FQmMOvOgmDVuM2CKWyzrFiNKWoxP
         o6P4sK5er5Vt5bAQAY4xyXrbUcJKSwOT1TJlLDLG9ODw1WK3MRSbZZtBabc2t9xNq9sj
         xLtBpwxX3SyWGFyS60QZgv2mupOqtzORE/1h6fPz34RqrzK9rj1bWE99l8oiX5EHdeHo
         cIQt9gdIax/XOmRXZ/1JY8APID8K16eescCMng8XaZjD9uWam7lWA5hSgwUB20hZSFcZ
         v21nyxzyYf2tN3zALCFUtH55kjJ4A/g7E6bTzeABP2+Swq4gjLFNGzO5zSJcU/9oGclD
         sBaQ==
X-Gm-Message-State: AHQUAubo/rXQ4ZgNBbplKcDJc744Xa1XjlCRfNz4/gkLe3bygy2KqFg6
	P72q2fmCoHQYmacl8Ls+F18sjt4AGEGbDyVK8bhGwLr2QVGUf+vuXX38sdvODB/xLS8Jxg/a8x5
	gDNRPBdsVmsEO6relz8IEw3O66C6Ozj2TTzOJd98pfmNNqeWc/cAV6qTNSYM7dPEzIUaR0svZ+9
	itdYabvLcxGd3kcdDdtiNeSNLizkIRtwXFPNZRmewgod4QzD7SMyIY94PttDhLfHCiYKVMcZQY0
	RRuIgB1KwpAlLZfIoXpE16Zg9tBzbGaqTcboNo8ZsQJnO+L4TmCJJNl6CtGh5ePqxwdMN7Fja3Y
	JVOstiKSB973Ri1wHyiwCFUEFohOlJkb0JgKRedShAfyZbUhCWWB1MN/tCerYz30ZuHLWggaHRA
	N
X-Received: by 2002:a17:902:7b85:: with SMTP id w5mr7787560pll.288.1550270654325;
        Fri, 15 Feb 2019 14:44:14 -0800 (PST)
X-Received: by 2002:a17:902:7b85:: with SMTP id w5mr7787526pll.288.1550270653739;
        Fri, 15 Feb 2019 14:44:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550270653; cv=none;
        d=google.com; s=arc-20160816;
        b=Xnw4RWrgLBBrVr302o3OrWv25hzYTw50G+4l6yP7yKrXkTTTIm0z/I2F1xwdvYpJab
         ViEo7FzPGxKilb4BoBfBquorrKHIk7KVIHyWtMgWsZjGjNlDQFFVl9wXaR2Tjr/dJ+jx
         16vx5Rsb++yblp1j4uVYmzZcrHmZnBxZDjS+k18c7BbFsdB3JqOmApC1lZ1S7cmzzyjY
         h4BejAmiVT0sXPnOEwl9U4d6Jg9ez0kdRN/NMSVYboImKrPXY/diW60g/XMPf6CxGNQi
         uj82ib04wRoIHayuZlTgIZM9VKqP3yPfkLF4tfhtla4koIemkrWZzh1ZmurP5uyImXFh
         z7kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=fS5mmi3aRfTJ9ZPKh6Kon1+z1mp8jA2r8sJju4C3jM0=;
        b=AFyr4AB1n3N/5yJRAehLnJZlOICaa0Kl4WvuDrKyJViTQyGuGpgy/o+AZit1Wqw6rh
         ffJk84P+TgCOUni6fiRaqgp/5CTEjOXudySq/lTDclpgFjDKh+pP2peZaw8J02YVgf6s
         Zx7BCQxkw0xVY197f34YJTUOB5dSgKGOOcDkQoH4sHYXFw6NfJyRHjHZhQpTvS7YkEkX
         At8VAzk5SOrdknRVDibyiZsx0QPHc2lSUGC4lt/UJqg6CN56qH6HRwGpM9uleB5tvs8r
         1JgBNA4x3MUATXXmrQ5sEsUFckIn/UKRq1KfO07yoL0MitERog4P4o/JJl/vjnOx34K8
         l7dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vNuDOMtk;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor10882136pgh.44.2019.02.15.14.44.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 14:44:13 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vNuDOMtk;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fS5mmi3aRfTJ9ZPKh6Kon1+z1mp8jA2r8sJju4C3jM0=;
        b=vNuDOMtkrRDcjIvM34cWSAhjWi7DaxwrterHweE+q54fWc02gttbQplAgtkMGyNr6v
         I5pndMGUmeOkbofpoyaC97EwN9KzR1zRBpflpPCI4ARgg0U/hKqTN5fW/AAaVda5cPfZ
         b84zF7FusWmjRjReR0vFfP4DUVPL+NOQrm11mSwHc0lMmzzBlO5rVR3JbrZBzQYP4z9Z
         pSnur8hx54zXmmXBWSlybPJts2l7U/YLOxfeYgjVP7MN/Z3tg0kQXzf12oKaS5gBGVfi
         5dHYwYCUulJb8mFugGLJFCLbloov8VTOs3L5D93afRafxF7f6CmjDrdfK1wGeEMjcNL0
         7o2g==
X-Google-Smtp-Source: AHgI3IYkBCGWWOk/DvbdZfHFtmtakVD4J0yB5p0EAn9j1LbuYjzDRQBwv3wF7ASJB+gqPc/s6VK9MA==
X-Received: by 2002:a65:65c9:: with SMTP id y9mr7720172pgv.438.1550270653333;
        Fri, 15 Feb 2019 14:44:13 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id 10sm11721400pfq.146.2019.02.15.14.44.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:44:12 -0800 (PST)
Subject: [net PATCH 1/2] mm: Use fixed constant in page_frag_alloc instead
 of size + 1
From: Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jannh@google.com
Date: Fri, 15 Feb 2019 14:44:12 -0800
Message-ID: <20190215224412.16881.89296.stgit@localhost.localdomain>
In-Reply-To: <20190215223741.16881.84864.stgit@localhost.localdomain>
References: <20190215223741.16881.84864.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

This patch replaces the size + 1 value introduced with the recent fix for 1
byte allocs with a constant value.

The idea here is to reduce code overhead as the previous logic would have
to read size into a register, then increment it, and write it back to
whatever field was being used. By using a constant we can avoid those
memory reads and arithmetic operations in favor of just encoding the
maximum value into the operation itself.

Fixes: 2c2ade81741c ("mm: page_alloc: fix ref bias in page_frag_alloc() for 1-byte allocs")
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebb35e4d0d90..37ed14ad0b59 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4857,11 +4857,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		page_ref_add(page, size);
+		page_ref_add(page, PAGE_FRAG_CACHE_MAX_SIZE);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
-		nc->pagecnt_bias = size + 1;
+		nc->pagecnt_bias = PAGE_FRAG_CACHE_MAX_SIZE + 1;
 		nc->offset = size;
 	}
 
@@ -4877,10 +4877,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size + 1);
+		set_page_count(page, PAGE_FRAG_CACHE_MAX_SIZE + 1);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size + 1;
+		nc->pagecnt_bias = PAGE_FRAG_CACHE_MAX_SIZE + 1;
 		offset = size - fragsz;
 	}
 

