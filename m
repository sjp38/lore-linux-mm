Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E289BC43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 17:42:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DFE521872
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 17:42:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="b4H+x09L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DFE521872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 345F78E00F7; Fri,  4 Jan 2019 12:42:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F4298E00AE; Fri,  4 Jan 2019 12:42:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BECA8E00F7; Fri,  4 Jan 2019 12:42:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFBCC8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:42:21 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so45228133qte.16
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:42:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:user-agent:mime-version:feedback-id;
        bh=kRlYgB93SwyWvMmFsQ09GSaI13D5lK2ibH7Xw6hHedo=;
        b=jRaS3emThSswYOJXt+78miNHwJ6pnMKZf+hiV9cHmjZPJd8xhn5/adf+kxmWUe6I4N
         EaxYdgT3Xn7kXN0h0FeC1R0CYjQ8UO/0Ez6oVEKFc4ziweyzkzx7MYuLaHP2Sd6kQXkJ
         DIjuJbUeRbdPwmdwNwL0N/37s3ZUA97keNvbJqEhdGEIj/fdFCbG9RSBEF1YW34CTh2K
         c4dEbhjBPpJYwxcFYcP/tIrxZsHVlnyyggg3Galhk+c4clv87SWfpekv2FspSZ3bJHKq
         3zbIkzo2N/pxrSDoh4dLMb6c8qcVUTHUsCo+/Gjs/yBih3R6IylOV9BawlcQ37djwVoW
         2gpQ==
X-Gm-Message-State: AA+aEWb7z0h6e/3qZHsV1l4O3x/wkSc9owkVCcHtzlgaY+NvGanrrLlS
	0X3OwmC8O2r3Pqatf+DeMactE4LgKOw+2Sp/yWVOtbSZwzvh3iQPIi1i6HbuAqsQleiaSoAVUoH
	tSCTVFjPcrLqzlVYNFirrGxW4aOgAJzHkXLyxHjWj9qzmYczOPvJA6CobE6fgJT0=
X-Received: by 2002:ac8:2fdc:: with SMTP id m28mr52735227qta.202.1546623741639;
        Fri, 04 Jan 2019 09:42:21 -0800 (PST)
X-Google-Smtp-Source: AFSGD/V+kb7HIiJnJU8pubyOWdH20NSy6JmxJ1rcRrklQKzhFg5txKlNuLl/OrJLLnwWVNGsbKm4
X-Received: by 2002:ac8:2fdc:: with SMTP id m28mr52735181qta.202.1546623740737;
        Fri, 04 Jan 2019 09:42:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546623740; cv=none;
        d=google.com; s=arc-20160816;
        b=ewJqvzDEzgzK0TG+oW5yNfA+gRviepShCrbQTuqRthfx4VRcA313uLoOU1tJ2DpqAm
         7mgn4VoTKIpSCzaldqoS87XZagZtIfzLMI8zpoBGZcO3bT30Z8CdROk3pAroNt/0lEG6
         t3QmZTPH7yos1bn5agKDLW+23HTothHdi6xgHGvJMJCJLuFYglfb4i9/pqfPANg+yYe0
         zpv/e1JKL18XSxOpSgS8exaY4tllOWpzlrHDMSMzt32cuwv69VZTmBwL7NsfaTngsBey
         52eu4fMA+E76VQMbanh7NIQg3q9gJ2mErSCazm3wcMRyQ7pHvhcqMzjLmsZRjT70YMoM
         Q3jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=kRlYgB93SwyWvMmFsQ09GSaI13D5lK2ibH7Xw6hHedo=;
        b=x3YOr9eSeN5ElPIRyhQq5R7yApK/2pZcKb7INXtJJSJ9ytrWZDXarAEA1UoLmcxJJv
         Lk2dRqDI2eWLKc7JAD+V6IbF3Ll4xd9KxThI0TqJWyXQTOIf34kcotwH97M6JFKx7Viy
         +KzF3OIQcya1pYv8JCPOOh1WHdF862wxZ8Su3/7zd5xE+Rl9aQAGBBjDXFndF13xkLO7
         8NG7J4rMSfvLPQLCh7F6qLNpMg3pBTxleZqef3y0Oa1qGxhiEFZv/t13uksR5vlpFnR1
         F1JCvfjPI0vkFGNN0LY7HHj8q5VwO4lP+mgTDRzVnDfnEIwB30zMZrmaDwlyrVTLxr2D
         HiNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=b4H+x09L;
       spf=pass (google.com: domain of 0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id q129si5080899qkb.189.2019.01.04.09.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Jan 2019 09:42:20 -0800 (PST)
Received-SPF: pass (google.com: domain of 0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=b4H+x09L;
       spf=pass (google.com: domain of 0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1546623740;
	h=Date:From:To:cc:Subject:Message-ID:MIME-Version:Content-Type:Feedback-ID;
	bh=PL5ZHGs1jrB92OUdvNdjQudIiBDPP7SDTB3Z8/A1nH4=;
	b=b4H+x09L8r+R5BL0g2mLqQ9qIhWMP4+DQRcZRhTobaZSSEpaXXeBuxLnCH6IvroV
	Sfe8cd5J6kC1qrsHyKLqKTrRpT1FeC1AFPHNktDSdMMqTd1vQMiK9iFtLOuYxfVAIMM
	66Bl9d6Nk1iaz1ZYYEYfAl/DYuRGMMj4cWoZ4soc=
Date: Fri, 4 Jan 2019 17:42:20 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: akpm@linuxfoundation.org
cc: linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, stable@kernel.org, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [FIX] slab: Alien caches must not be initialized if the allocation
 of the alien cache failed
Message-ID:
 <0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@email.amazonses.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2019.01.04-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104174220.jfXPd4t24w8VtM-tXmjth1kbxHKT-WZ-SUheZyg565s@z>

From: Christoph Lameter <cl@linux.com>

Callers of __alloc_alien() check for NULL.
We must do the same check in __alloc_alien() after the allocation of
the alien cache to avoid potential NULL pointer dereferences
should the  allocation fail.

Fixes: 49dfc304ba241b315068023962004542c5118103 ("slab: use the lock on alien_cache, instead of the lock on array_cache")
Fixes: c8522a3a5832b843570a3315674f5a3575958a5 ("Slab: introduce alloc_alien")
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
 	struct alien_cache *alc = NULL;

 	alc = kmalloc_node(memsize, gfp, node);
-	init_arraycache(&alc->ac, entries, batch);
-	spin_lock_init(&alc->lock);
+	if (alc) {
+		init_arraycache(&alc->ac, entries, batch);
+		spin_lock_init(&alc->lock);
+	}
 	return alc;
 }

