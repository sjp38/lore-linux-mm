Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E408C28CC7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 06:34:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F78027C13
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 06:34:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JeweOGjj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F78027C13
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9B496B026A; Mon,  3 Jun 2019 02:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B247F6B026B; Mon,  3 Jun 2019 02:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A2266B026C; Mon,  3 Jun 2019 02:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5F86B026A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 02:34:36 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id k22so12874105pfg.18
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 23:34:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=R+hQLAUcVNWROrMbU90MxMOWiIFmUVyPvMT6jkT1W4o=;
        b=VK9NS0vl0h7CjGOFImH7u1tmrsdQI+0XlVEfHxIbGumcLs7ZL+3vTd2b4TwF49Eqbj
         08n7oA9yw92PZyXiw7xP54Bh5i0SN0KZd5/X1mjiRN0mzwQ1dHad6+T9hHY8I5TfhOk8
         7r8W5I9PfJ0nPQ80FUzl08A4nxP1QBLHdxcdoiE0yqyr1dWiNIY6gXQ42emWOXAQ07k5
         SzsY7Romye2T6/oxfVS6lD1/2MI+VBamZHdOzEUGpef8qhN/F9NhtT1bGGUNMVEHVIzX
         mKdcqni6Bb8UxlhvE9Yb+AUGIVEfmiJY6hptXIsqhuniRfC8gOyJoKpeHszCyJItINym
         qN9Q==
X-Gm-Message-State: APjAAAWzmJOvzIhQYc6qLgW6YTE6OUS8Lw57HHpowQ1iH5WWCPxuPtrz
	mpm0sOio4KYOKCJfPVXCXqBNqBuUf1pqhk7pqhWBXXD9gm3XRt8XCcF9Ts3qC1mpT3fDzNf5/uq
	1cHOmr8eNMDrVwQkLuoUamt/vbJ5Krpr2FN5qFUIXxEvCfNIAHuDMD2y3fYF6QDp78w==
X-Received: by 2002:a17:90a:9504:: with SMTP id t4mr28210629pjo.100.1559543675901;
        Sun, 02 Jun 2019 23:34:35 -0700 (PDT)
X-Received: by 2002:a17:90a:9504:: with SMTP id t4mr28210588pjo.100.1559543674819;
        Sun, 02 Jun 2019 23:34:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559543674; cv=none;
        d=google.com; s=arc-20160816;
        b=gA1evp4Ku/ddNsFYC2trjdHXnpFEn4wRulzQWkhe+mfNOJlVX2e1elQvhdpoKlcRcj
         a1oasiQVRV0IY1PyvxE4t01EyNsha7Y2+rCtKFVVXRwak9D7Ba8GWR4dbEcyebWL6sei
         Ba23kunPap42JTmZgXOrOHVamfNUiDb+IajJvHYc8jML/I29p1guBxtabYP+4y3UTTcV
         vtVhJH0o8vKWNnQ89mYc/TXLO7UdabkVmGiEz6dlXUheTVRpp7vPatZpFXY/lpf4IA8n
         3qhe7kixBKx7hhXd0baLPD2KzrP4Q6oy6u96NoEfQ5R5XOfqc4RLcXEtNWXcKYF89wRW
         kllQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=R+hQLAUcVNWROrMbU90MxMOWiIFmUVyPvMT6jkT1W4o=;
        b=pJLdt2SJHjmDwfoR97sRiY4yPKV6tkBC37VFn0fMZihVIiL8tLHcfn72CtU4lWmECb
         1VYiZDfRoxQc9Fxw/VE/oRoTg2sG2uZKwvxbnqq3ST6/u20GsET+IMerjAQCWjINY7s5
         hhvRltI30gbviGS5jnL5kgIAgYB+zzkAj/B6PgMk//7abC38oTQ6o06NDFN3USA6xH9O
         bH/GrPoj1EjaXrIQNQBx1GynA3vaYsvKlCunQ0ULh6G+dW6Q7NSlw9hCOVHMQTPCMBww
         xHHDLz8xhNFwk1Q1fJxSZQLfXhKifWeZby5weX78AcogKtwKplvgR6BuoepBUuEV5N1h
         a79Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JeweOGjj;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 59sor10177662plb.14.2019.06.02.23.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 23:34:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JeweOGjj;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=R+hQLAUcVNWROrMbU90MxMOWiIFmUVyPvMT6jkT1W4o=;
        b=JeweOGjjlqVIH0KxKJuMpIq1jSl5UooWsZl6FxhuW8sb2MrVdCeODLdOoT53EObqUZ
         4qjqklXB8sKCdnrChJYqiO2zwJFomiMOlfWPl/vGQHgSbOXLj/ZLI63GKQJPmNc16MiQ
         Gtu2Zndm8bSdcTbZ5IgIceYQ0+Y0UKAGwEDJEBVLuPfmUidBnMkozY/geDaUTJLyDzRS
         9Ad79TVjhULakP38inxlO4HWvIVyy/C0Z2vuFCmg8zNuXIz0ARsxoWQ1M1PdLU0fVXQ8
         +bV2Y1lvl8+TzKbz1LCnhDqSfNI1mwsALbONIGIuSbcLgLiaYXVT+Dh4vKyRBKAGJS9L
         wOdA==
X-Google-Smtp-Source: APXvYqzm7+kJNYspgi7GV1P/I+D5ucOoLPIk/Mc2TPSNdzWzx+ipIDi9/crR7STfyeeK+Yteix/HFg==
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr27518004pld.286.1559543674435;
        Sun, 02 Jun 2019 23:34:34 -0700 (PDT)
Received: from mylaptop.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j14sm13859027pfe.10.2019.06.02.23.34.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 23:34:34 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv2 2/2] mm/gup: rename nr as nr_pinned in get_user_pages_fast()
Date: Mon,  3 Jun 2019 14:34:13 +0800
Message-Id: <1559543653-13185-2-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To better reflect the held state of pages and make code self-explaining,
rename nr as nr_pinned.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6fe2feb..106ab22 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2239,7 +2239,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages)
 {
 	unsigned long addr, len, end;
-	int nr = 0, ret = 0;
+	int nr_pinned = 0, ret = 0;
 
 	start &= PAGE_MASK;
 	addr = start;
@@ -2254,26 +2254,26 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, gup_flags, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
 		local_irq_enable();
-		ret = nr;
+		ret = nr_pinned;
 	}
 
-	nr = reject_cma_pages(nr, gup_flags, pages);
-	if (nr < nr_pages) {
+	nr_pinned = reject_cma_pages(nr_pinned, gup_flags, pages);
+	if (nr_pinned < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
+		start += nr_pinned << PAGE_SHIFT;
+		pages += nr_pinned;
 
-		ret = __gup_longterm_unlocked(start, nr_pages - nr,
+		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
 					      gup_flags, pages);
 
 		/* Have to be a bit careful with return values */
-		if (nr > 0) {
+		if (nr_pinned > 0) {
 			if (ret < 0)
-				ret = nr;
+				ret = nr_pinned;
 			else
-				ret += nr;
+				ret += nr_pinned;
 		}
 	}
 
-- 
2.7.5

