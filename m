Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 041CEC4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5D6A218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uNtKfSU0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5D6A218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99E578E0173; Mon, 11 Feb 2019 17:00:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 925218E0165; Mon, 11 Feb 2019 17:00:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812258E0173; Mon, 11 Feb 2019 17:00:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD948E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:06 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f5so166598wrt.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:00:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F0+Fcs0MkZYX4znEMfQAn1VdtYpI07PvV8ScTPU9zPg=;
        b=nt3lLXLrHUxYGi1AfB9Kz1xdToDvhdEhM3f69IdBKg+9d6A3a/nSxJpASwfmxzC5dK
         o06NnpH6jnmUJHqonwL/P9Buhk/sHqbf99jzPEkxDlBVSL0fO2OMyUFAyIv7/+LbMHHL
         KKYhEZx7Qz0knIDuXnNoyceqKpFmYKe2xmDFZ0hs+u+iTwdJ5Fcpe9VmEyAN3wwCC0F1
         EgBuw77BQjqW1Pu8lgRUEno7bvtzFJQMIMkxTRsXmuBTnG28+z48nk4joAhRjxSdEUE6
         Cf08ulmQ0+6Zd+AmQunFjfcO3AIujZnlUAVAL7frExmDlW2dF8mLsrRktxIca2zU1zQC
         43Ng==
X-Gm-Message-State: AHQUAuZJ/EOB2OVfLUzfMpF7sN96JW5v7aepLv1CdyWpZ+hbOlDK/2n3
	zNyN5UV7J2ibRrsMziMKydwvhptyerYzLrHJZh+rEBoJoV8wRrQhrY8NknyE71ylXKBXRQQCNHF
	tT4gWmasJxV0OBDhAAfA3Qq0xA/jnb9rcHiMDlX0gOVegeHONZ5H+aaLXrhB5lPunGB2aAj7B0o
	fJ4JwieKRe3QMTOYluuzp5QsXOmsPADgardtnNGzVdJm/QJdZ3k3jeq7oU2UeGExTFfBlsINZ/H
	tkOe/jk8Za8X2m/Rot4OyiQ3kt9lOtAxwqocMVl1A+1xwgxW8Ljyz56k6V7HM52gAdtMNqXyhmt
	7tX306P2rRGEiJ7Xw1yDUYpc5G687oiTEmUKn+NUpyQ3Lg0xntdjWo+VVJkRUAfzSBxYnoTJyvu
	j
X-Received: by 2002:a1c:4889:: with SMTP id v131mr273469wma.146.1549922405702;
        Mon, 11 Feb 2019 14:00:05 -0800 (PST)
X-Received: by 2002:a1c:4889:: with SMTP id v131mr273430wma.146.1549922404880;
        Mon, 11 Feb 2019 14:00:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922404; cv=none;
        d=google.com; s=arc-20160816;
        b=kEgs9TjlukhQceFlIA6NueKvyuehG0vRhryNfcX8AmdfVt98gmhv2E7wbpB0dSFjjC
         ohei0lAA3rCrH6G9EhWjtP8VkRlt+4OmB8FLUcGQqs2gXTQvUbrGRYfp13Zdp/0sBDwv
         d2X2PeE/I4udOVlDUHzmLfpdtFPs0i6MCv2z89v77lMQwOIYjJ8BYTRQi03mZfI1+SzO
         S24ne5kF56OyCvvJpt887GUPa7o5icRUwE3S3bOarYCuHJxkFGQU75RqurgJz0O/oUTg
         //PAYTQJkGIDLIOkQU7z0FK2ZfRvzuym4JDbJ3ebWCeu7DG4abU25SLGMbDutt3jIKln
         wxUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=F0+Fcs0MkZYX4znEMfQAn1VdtYpI07PvV8ScTPU9zPg=;
        b=Xff799SISONlJQLu8W+mclhQNNJ5U3DMRe9CUPscz4Uu2FdsGrz7B4AkGjZmu7Dt2x
         hh6v2aZvrWk6PHgj06BMTJSK/DeRkqn4iS9BHcNJhDsaNw99J5XLNqgYtARu1p1OYadK
         2/BYvOfY7YodtQk8YwooNiPA6lAo2H89RKTQQXpuCJVkeUdKL4veiIkX+ycQra8GV8m/
         +ZCLSkDMSrJlziBpSuk9ph0NuJfO0rY35VJyEK6bzJu+Tp4l7oJw3EoyytHkFbiVn1f7
         ESfQpcph4NWEE91zcgEbasupM3pMh/tFx5fOeLWmdneMfs0D8bh/Qea7tk3cQnlCZQsA
         jW1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uNtKfSU0;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor2097101wru.38.2019.02.11.14.00.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:00:04 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uNtKfSU0;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=F0+Fcs0MkZYX4znEMfQAn1VdtYpI07PvV8ScTPU9zPg=;
        b=uNtKfSU0+K7DQuJSpKocOX08Ends+VIaoncwv193IfyXRrFVBQloeekrKLHBO18zJ+
         zgxP0BRQ7dybUbH+vvlFhWtPeIkxhDeFGx8FBjvlB1pP+wWRqrGLu2HYEJOpRkV7GgjH
         BV2TCh/BIeC6nu5Qwb5AAvBUgtIeZ1UmePHyqs0aczpO/b5xxwOtVzf2zPECxG+vAXtI
         USdX46+1WMxKTGo+3PTXad80sHiFx42Ok1No2ZWmb3msF+2NZovofxW8GFu72nSWw2a8
         a4vWaXFgyVh2aXX5PLs6hV9WY5xx9ThkNZJd+fyIYLSzO1/eNL4iNZoyP4biKgrNKM+H
         +Kvw==
X-Google-Smtp-Source: AHgI3Ib27D4nBRNkQKP/Nr0Yz3dEkA16v3GKdYr81WW50n3+gRxUrezwoWqu+5gij6CSI/XqL3XXBg==
X-Received: by 2002:adf:efc8:: with SMTP id i8mr307497wrp.164.1549922404424;
        Mon, 11 Feb 2019 14:00:04 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id c186sm762685wmf.34.2019.02.11.14.00.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:00:03 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 3/5] kmemleak: account for tagged pointers when calculating pointer range
Date: Mon, 11 Feb 2019 22:59:52 +0100
Message-Id: <df99854703d906040a7a898ac892167e3ffe90d9.1549921721.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
In-Reply-To: <cover.1549921721.git.andreyknvl@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kmemleak keeps two global variables, min_addr and max_addr, which store
the range of valid (encountered by kmemleak) pointer values, which it
later uses to speed up pointer lookup when scanning blocks.

With tagged pointers this range will get bigger than it needs to be.
This patch makes kmemleak untag pointers before saving them to min_addr
and max_addr and when performing a lookup.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kmemleak.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc250428..707fa5579f66 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -574,6 +574,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	unsigned long flags;
 	struct kmemleak_object *object, *parent;
 	struct rb_node **link, *rb_parent;
+	unsigned long untagged_ptr;
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
 	if (!object) {
@@ -619,8 +620,9 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 
 	write_lock_irqsave(&kmemleak_lock, flags);
 
-	min_addr = min(min_addr, ptr);
-	max_addr = max(max_addr, ptr + size);
+	untagged_ptr = (unsigned long)kasan_reset_tag((void *)ptr);
+	min_addr = min(min_addr, untagged_ptr);
+	max_addr = max(max_addr, untagged_ptr + size);
 	link = &object_tree_root.rb_node;
 	rb_parent = NULL;
 	while (*link) {
@@ -1333,6 +1335,7 @@ static void scan_block(void *_start, void *_end,
 	unsigned long *start = PTR_ALIGN(_start, BYTES_PER_POINTER);
 	unsigned long *end = _end - (BYTES_PER_POINTER - 1);
 	unsigned long flags;
+	unsigned long untagged_ptr;
 
 	read_lock_irqsave(&kmemleak_lock, flags);
 	for (ptr = start; ptr < end; ptr++) {
@@ -1347,7 +1350,8 @@ static void scan_block(void *_start, void *_end,
 		pointer = *ptr;
 		kasan_enable_current();
 
-		if (pointer < min_addr || pointer >= max_addr)
+		untagged_ptr = (unsigned long)kasan_reset_tag((void *)pointer);
+		if (untagged_ptr < min_addr || untagged_ptr >= max_addr)
 			continue;
 
 		/*
-- 
2.20.1.791.gb4d0f1c61a-goog

