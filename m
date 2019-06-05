Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55C9CC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 14:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E00BD20693
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 14:49:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xt1p4DdY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E00BD20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363866B0006; Wed,  5 Jun 2019 10:49:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3141F6B0007; Wed,  5 Jun 2019 10:49:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2035F6B000A; Wed,  5 Jun 2019 10:49:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E00026B0006
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 10:49:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so14931077pgh.11
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 07:49:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=n/tZofbBogKZ5HTBUbSV6rWcxAAFfPOtXDpX6liTabU=;
        b=KMBUvTpBDrjnFZAPVN7kp7Ma7fiUl54TfUAAod5fRyGZHyG7roHNc01u7ZDv9GqpdQ
         5z2kl2ZseHWV3Fhem3w3qYSFV3Yu+x1EQ0b/BfDxdKo3WMzqo7hCek4d6l0krj0VMTPp
         Df0whEuBcB0Wz9pTiRCF5FlA1LplcpF0AQY/Ke6oD9gM4hMa3KSkLhZkK1BKkSJ3+e/Q
         Sgc9I+IYw5dSwm+aHlcsCQAy6yjWA+cL0aJ2cfa2Aene6X3M5hpi5YaKmb+wM4YjbLJg
         tK+1G0BZH/c4zMMEczuL9SOiWsrcqfbJxn6a+mJ3OsV3TkozFcf5pNYx+ENmzZYNQwci
         hcrg==
X-Gm-Message-State: APjAAAVfh+uI8p3XE+cSPtnfFtbZ1ol9im6wAb6c8KlUbQZizm9eEtOo
	xchl615/Rq+S+TkWIPq7x9Y863vae/AqJsY4MfkYe9tDOT0TM+6r68V2dPAkhh5UxApskAbtHfX
	ZOtFlJH9sKCc4rzFm5ttCfD3qad/kXqoSyEwOFh1AuUjga/GIqc4izKjpdJI/T7xxgg==
X-Received: by 2002:a63:6e48:: with SMTP id j69mr4928484pgc.34.1559746161267;
        Wed, 05 Jun 2019 07:49:21 -0700 (PDT)
X-Received: by 2002:a63:6e48:: with SMTP id j69mr4928322pgc.34.1559746159737;
        Wed, 05 Jun 2019 07:49:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559746159; cv=none;
        d=google.com; s=arc-20160816;
        b=TX56CDykETvSfuLAVli1vQUy5qS7Nck8T0H70YUKPE1JQIsQyQzgMIjbVcqiQooTIs
         cwWfp7dnX5EV3TI58lyPiXRRi4Mj1VugvOGkZwsNEQUvVuqCx5Na7XwB933cLHkQ7XlY
         a9i9QtntG8cR7+VoulXjTlniQ8qXr2IbwW2VoILCVlkAuZuUbeEYqjv2fF8lwDTRn2SL
         ygul2vqWKItrIQaGmPwiEuGSwaoFn3+SxWuElBsjmPXcM1Cef9aG9Cfa5rt1VRqy0f5r
         gMToeofihsPbOYKh8khyPX/QxXbMr0a3/gGuIvsBP5j4XY1cfY/lM6cHw271Evmjoh8h
         zT/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=n/tZofbBogKZ5HTBUbSV6rWcxAAFfPOtXDpX6liTabU=;
        b=MJ+HiIMYYY/4/WsO2XdqRVOFWAbfoS2hoZ8ZWBPKLNIAktF59pQzL4hcCCxZZuk+73
         oaueLy5I5N5m4zDhVusZFE6VZm85aVltMNAQ0P8Z9r8oTHiEeCZJkxFktlLQq/eJx+6g
         r5Z0BQ+8AIegktnWo5OwXguMmWwXI5J1Ipu0rFNf1qAR9WZlZd3/Mv3rsqUnesqkzy1d
         foWwMEQOPJwhrc4MzK6+AjZtbogXKqWIkZQpK8dP15o1kH2zwqRVz5HQ1UUKaDre1ado
         KVUu+93Bbdo/1WPpSOVrpFSSugnvE+Fqm+XR9cd5YehhqGWzdDuoJh67Tf0Rd9YORn//
         WW5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xt1p4DdY;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19sor14396498pfr.25.2019.06.05.07.49.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 07:49:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xt1p4DdY;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=n/tZofbBogKZ5HTBUbSV6rWcxAAFfPOtXDpX6liTabU=;
        b=Xt1p4DdYpo2iTbRqldHe1m4pbYWezS+2NvUE8s9WGrvQ32mQm/SvJ95a+v5FCwvhdU
         uqsVALe56+yi0vvM5IqsD2+B0U3wt3mi4jPtG98X84/K4ZoJscczxTB2FTr2kalU7QK8
         QSodgzdiM1cHC8jLZ18alaSGJ3nAp3XoBqOFU5A8CEy3WV2rlKZx9RxnQOHgpV4zo4oJ
         CppFN9hDpmIhW3P0WfQKj5WDkYmLQKU1W+qF8L5Vjn33pvdVB8asrbfEEzdHdBvTGSPo
         N6+kKFpe8QK6I1vGkt9zZfHzCU4hbgxOeDyHQC0m4Z1/n87MhLnjpbJkVj+rPlVtc+pG
         tveQ==
X-Google-Smtp-Source: APXvYqyBbhev4RKfSBMh3SGEtpfz2O+6DtVwVokbLlv0pD8pFHlxodfBt6wDsYpKmza793o7PvgMMA==
X-Received: by 2002:a62:2643:: with SMTP id m64mr45312432pfm.46.1559746159262;
        Wed, 05 Jun 2019 07:49:19 -0700 (PDT)
Received: from bobo.local0.net ([203.220.89.252])
        by smtp.gmail.com with ESMTPSA id m19sm13375840pff.153.2019.06.05.07.49.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 07:49:17 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/2] mm/large system hash: use vmalloc for size > MAX_ORDER when !hashdist
Date: Thu,  6 Jun 2019 00:48:13 +1000
Message-Id: <20190605144814.29319-1-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel currently clamps large system hashes to MAX_ORDER when
hashdist is not set, which is rather arbitrary.

vmalloc space is limited on 32-bit machines, but this shouldn't
result in much more used because of small physical memory limiting
system hash sizes.

Include "vmalloc" or "linear" in the kernel log message.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---

This is a better solution than the previous one for the case of !NUMA
systems running on CONFIG_NUMA kernels, we can clear the default
hashdist early and have everything allocated out of the linear map.

The hugepage vmap series I will post later, but it's quite
independent from this improvement.

 mm/page_alloc.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..15f46be7d210 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7966,6 +7966,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 	unsigned long log2qty, size;
 	void *table = NULL;
 	gfp_t gfp_flags;
+	bool virt;
 
 	/* allow the kernel cmdline to have a say */
 	if (!numentries) {
@@ -8022,6 +8023,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 
 	gfp_flags = (flags & HASH_ZERO) ? GFP_ATOMIC | __GFP_ZERO : GFP_ATOMIC;
 	do {
+		virt = false;
 		size = bucketsize << log2qty;
 		if (flags & HASH_EARLY) {
 			if (flags & HASH_ZERO)
@@ -8029,26 +8031,26 @@ void *__init alloc_large_system_hash(const char *tablename,
 			else
 				table = memblock_alloc_raw(size,
 							   SMP_CACHE_BYTES);
-		} else if (hashdist) {
+		} else if (get_order(size) >= MAX_ORDER || hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
+			virt = true;
 		} else {
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table which
 			 * alloc_pages_exact() automatically does
 			 */
-			if (get_order(size) < MAX_ORDER) {
-				table = alloc_pages_exact(size, gfp_flags);
-				kmemleak_alloc(table, size, 1, gfp_flags);
-			}
+			table = alloc_pages_exact(size, gfp_flags);
+			kmemleak_alloc(table, size, 1, gfp_flags);
 		}
 	} while (!table && size > PAGE_SIZE && --log2qty);
 
 	if (!table)
 		panic("Failed to allocate %s hash table\n", tablename);
 
-	pr_info("%s hash table entries: %ld (order: %d, %lu bytes)\n",
-		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size);
+	pr_info("%s hash table entries: %ld (order: %d, %lu bytes, %s)\n",
+		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size,
+		virt ? "vmalloc" : "linear");
 
 	if (_hash_shift)
 		*_hash_shift = log2qty;
-- 
2.20.1

