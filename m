Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC65BC43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:53:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A20FF2082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:53:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mag0NQ/B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A20FF2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F17F6B0008; Fri,  6 Sep 2019 10:53:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C8156B000A; Fri,  6 Sep 2019 10:53:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DE066B000C; Fri,  6 Sep 2019 10:53:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD3F6B0008
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:53:31 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id ADD2B181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:53:30 +0000 (UTC)
X-FDA: 75904789380.19.corn58_58ccd3e67e337
X-HE-Tag: corn58_58ccd3e67e337
X-Filterd-Recvd-Size: 5632
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:53:30 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id t11so3283370plo.0
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 07:53:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=y1UWMqHdCnekLv2dWzC/1NNH0fQiwzlC8Wszz/ILY4M=;
        b=Mag0NQ/BaY/evlZK7rDqVpVa4SoD20yegY2gnU1J5QJ3cQlPeV/WcjiNsMRjYj4UlO
         j47A4eB1Yyu6XTdDMn6pahVscdhXahzaiE5xjJhESZqtYaG0lzLUqBsiW6/Fy9NG09xg
         C0aLIvy/oDX59quZyauouhcpPyWzxdO81zIGT2WvnflPokAj/pLHMhQ3mj+xzsqp14Ls
         7ab/Q7uvHBNht0vduEP9dnyrW2UuVdwFLJ4a6jdGsKR41YoqTUo9nnlYCGO6X4dQ9RcX
         uROSr2vodVMG9kRIlO3cfEccObq9fvrETCZcgM7na40pGHl+LKkghJ1Aria9vjVlnarm
         gZnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=y1UWMqHdCnekLv2dWzC/1NNH0fQiwzlC8Wszz/ILY4M=;
        b=Yscc8rHRYvmhP3oZQf0ttZVR/5xFf8fvGm0q+lsZ7W1j3s+axkNgBHkvdgzl08EKZ6
         0kK/ggUQhfVos01qGKsO0Yee3Ir72PT3eSXdjffyeCWFbjSgh73ONtamGa+iqE2ft0BN
         gQGGjaYzz3YXvbJPMHSaiptxaA9g5g4yAphct+84ltE+c/ePj6E7KDI+JwI4xH+AZZ2C
         E4gX1s3sre185aoIqYMwunpVJPnYd9vvy/9r2yO8SpIdNsyukRxR2IPNtSDUZ7SllzwJ
         LloO0s0T8aYunhmwvWxvQcIfA1z4jkbQebeJwUtt+bOy3DuVN51rZkvGXzrXkT0nvq5G
         zkMA==
X-Gm-Message-State: APjAAAXgrUz/UJwvrWbXrZn7/52nw9g3dO+f10B+LlmE9ee61xs4rUf7
	GSPp4v61KrFXijoUZ4+yJdM=
X-Google-Smtp-Source: APXvYqwXbA80G+oF/wmxkLk0iz+eT1kKPHeORFg6MaYksK5+TYFebrUDE34FVzIfkIJ4DDYs9NYZbQ==
X-Received: by 2002:a17:902:a01:: with SMTP id 1mr9873072plo.278.1567781608953;
        Fri, 06 Sep 2019 07:53:28 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id c1sm11390068pfb.135.2019.09.06.07.53.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 07:53:28 -0700 (PDT)
Subject: [PATCH v8 1/7] mm: Add per-cpu logic to page shuffling
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Fri, 06 Sep 2019 07:53:27 -0700
Message-ID: <20190906145327.32552.39455.stgit@localhost.localdomain>
In-Reply-To: <20190906145213.32552.30160.stgit@localhost.localdomain>
References: <20190906145213.32552.30160.stgit@localhost.localdomain>
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

Change the logic used to generate randomness in the suffle path so that we
can avoid cache line bouncing. The previous logic was sharing the offset
and entropy word between all CPUs. As such this can result in cache line
bouncing and will ultimately hurt performance when enabled.

To resolve this I have moved to a per-cpu logic for maintaining a unsigned
long containing some amount of bits, and an offset value for which bit we
can use for entropy with each call.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/shuffle.c |   33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce12481b1dc..9ba542ecf335 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -183,25 +183,38 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 		shuffle_zone(z);
 }
 
+struct batched_bit_entropy {
+	unsigned long entropy_bool;
+	int position;
+};
+
+static DEFINE_PER_CPU(struct batched_bit_entropy, batched_entropy_bool);
+
 void add_to_free_area_random(struct page *page, struct free_area *area,
 		int migratetype)
 {
-	static u64 rand;
-	static u8 rand_bits;
+	struct batched_bit_entropy *batch;
+	unsigned long entropy;
+	int position;
 
 	/*
-	 * The lack of locking is deliberate. If 2 threads race to
-	 * update the rand state it just adds to the entropy.
+	 * We shouldn't need to disable IRQs as the only caller is
+	 * __free_one_page and it should only be called with the zone lock
+	 * held and either from IRQ context or with local IRQs disabled.
 	 */
-	if (rand_bits == 0) {
-		rand_bits = 64;
-		rand = get_random_u64();
+	batch = raw_cpu_ptr(&batched_entropy_bool);
+	position = batch->position;
+
+	if (--position < 0) {
+		batch->entropy_bool = get_random_long();
+		position = BITS_PER_LONG - 1;
 	}
 
-	if (rand & 1)
+	batch->position = position;
+	entropy = batch->entropy_bool;
+
+	if (1ul & (entropy >> position))
 		add_to_free_area(page, area, migratetype);
 	else
 		add_to_free_area_tail(page, area, migratetype);
-	rand_bits--;
-	rand >>= 1;
 }


