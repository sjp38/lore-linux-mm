Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7E1DC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 576AA218A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KNkhOp+F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 576AA218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0DA98E0171; Mon, 11 Feb 2019 17:00:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B95AB8E0165; Mon, 11 Feb 2019 17:00:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5B658E0171; Mon, 11 Feb 2019 17:00:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4DC8E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:02 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e2so158187wrv.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:00:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9CMPZjRzPxA9yWJGkQniQIkHzZh/Nj3CjJ78bKTFu6c=;
        b=qX+/EvH9bEGba0pvWNaioabU0s3Noy+dGhRemS3tqNgTQwNgImV392gxADA5V1rIJB
         dwltw73UBBUbzx38QLIjfTUsv7Ju7DEuQh4pqyhdQcNZqnyJmqYjaVIZP7UOk2GVRR3i
         Fz7EWxHd1Sulip6rEf9jXhLEhiUMDBgkAp8AiXiLlMOOp3afgvNQDadnFYiaSIKq/zQD
         kBf+jyyL+uO5reHwnA2sM0jnhqj9xZ3m9AU1qDjCt/xy3tegzIz27K4wL7m4Ty0DSVku
         Y8wmNbKVPahPkA1h6Clpz5wVMO1thblBYYlzFMaDPoLEFmNQQkpQ42Nz/NB+LTGJfmhV
         PRAg==
X-Gm-Message-State: AHQUAubdmvx9/iJ/SiOqmQdZ2Tkoyxxz2nUxf0RadU6YwRghPHRj/qxl
	paz+bWThoswY08gTva1mCQpMCqK826eTlVcWxSNBGTT5BL4peFK2ckLH/sG0EEeDytzo769rgd8
	u9TQ0ZDfmIvBR4WRiaFBncm8O4wORLQrb+EmsEjbag++7APpni/lo9T46nTgi5NT56D51Km0viw
	SfjJNGO7IU11LnSGRyDymdZcOMNHsZ3mv0/B9v8CnoJxZf731tURrjEfYaxOI3jGJuhKMi0LY1n
	UOAD5fEQAgIIIccWAVdHfk2aKMPgGm4DQH+iHgZmiJiufrwEcq4peKqehehoxkk0Bj5X55L8vdb
	JYUqPp1R128xjaJHhO0RxgUD1v/ZPZqSRgBCuPk0ZAUVTuvWrj/kCusr2b+jaaVAt8f2SIY+xHF
	S
X-Received: by 2002:adf:f28d:: with SMTP id k13mr312982wro.78.1549922401828;
        Mon, 11 Feb 2019 14:00:01 -0800 (PST)
X-Received: by 2002:adf:f28d:: with SMTP id k13mr312950wro.78.1549922401054;
        Mon, 11 Feb 2019 14:00:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922401; cv=none;
        d=google.com; s=arc-20160816;
        b=EQj/9NaG45JJ3mS0/3dgHZP0L7C3dh9jMk11PoM2/zAnry7uL9jZwQBHmEBwjt4kLQ
         KMNAI3PAGwxmeR680Ct4mrMmxujI6Gz/OVVuoVWvjGQ5HuJgKSLF5bKxnMHcdfyEdYB+
         Vt26nfQyrHIWPOui5oKbcii+aJWt0kYX1tZqQYjQquRihwvI4mBhL6+HAuN1cW8SPd3s
         7WuwTOrMJ/TMReSrDGesW6CpSBTMzSL+D73v307idGxxDutcVkLfLgk35Lc0XtNEdne1
         Kqg9WJ+KhmmZWKHAdVm2cI1aXQeV4P0Qr30JjJqP0hX5CNrQ+qz/6ixgDpso16FVA4O5
         3HHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9CMPZjRzPxA9yWJGkQniQIkHzZh/Nj3CjJ78bKTFu6c=;
        b=0vKOlm4VG4XjbSccAEmhtDuyoRuNnbFr4Ic4P0Ch0iKSlZfrZo40vF8r+41JkZigU4
         Z2F3PYtyb8nsA8qXoffyh3nkGOHY4dEtCmTE/OmrtkmdVuZ+gTEhjsou84ngAXXbiHHY
         iZd2vsD5CAHg4VfqwtFOq6I/Rh93BQIXl64MyCoHJjmbixGHkFuYu1kJaeZBx13QOp7Q
         anjcbb27M/GvTGtn46AVFjuj/C1edHQevT6DhZuMYv2b2igXooQrFxQTXH9a3H7VWBf/
         TG+S7nvGxxvG1eX/vjTj2O/qyIIDvgCNuhZYZGoCIfcy5VcOB9rHiS1DYeJoc0O2u2rx
         AEXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KNkhOp+F;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor2669105wro.1.2019.02.11.14.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:00:01 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KNkhOp+F;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=9CMPZjRzPxA9yWJGkQniQIkHzZh/Nj3CjJ78bKTFu6c=;
        b=KNkhOp+FwwqqWNp0rVoktr8lfQk/kt4OYWfZh0XzvAGg0XcRsG1vZ9foQ6V5/GjZQS
         ZtJd4pn78QAAV9XHc7Hx7Po325azOyAcAntab5T7pxquIxMo4L5vhod2HvO4oM0JS1sJ
         5wW/NCzntc/d2udqR3ieGxAD/HSjnEhECEe9Jtfv+F4yBFFMKB35cnTfuEvhVsSWOeVu
         +GBkc+Dm/3w7rbgZQAzXnDfuP3Nz8Rm1s91ixQQMVwwZfyBKL+2PEnZWizwZGxiicisf
         k+fqqLG5MgEygXacHs7JJeAcrMzplL/EfvnKRModlnR+xpLr0M1favDp3jNGs1v8W9MD
         FtMQ==
X-Google-Smtp-Source: AHgI3Ia32u1Rwu6dEWF9OS009TTKjKG2ZLzjUiuLH7ytuQiqzKENoj77khlFOGtz0NDNmqx4HNgfdg==
X-Received: by 2002:adf:dfca:: with SMTP id q10mr284447wrn.45.1549922400500;
        Mon, 11 Feb 2019 14:00:00 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id c186sm762685wmf.34.2019.02.11.13.59.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:59:59 -0800 (PST)
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
Subject: [PATCH 1/5] kasan: fix assigning tags twice
Date: Mon, 11 Feb 2019 22:59:50 +0100
Message-Id: <ce8c6431da735aa7ec051fd6497153df690eb021.1549921721.git.andreyknvl@google.com>
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

When an object is kmalloc()'ed, two hooks are called: kasan_slab_alloc()
and kasan_kmalloc(). Right now we assign a tag twice, once in each of
the hooks. Fix it by assigning a tag only in the former hook.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/common.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 73c9cbfdedf4..09b534fbba17 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -361,10 +361,15 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
  *    get different tags.
  */
 static u8 assign_tag(struct kmem_cache *cache, const void *object,
-			bool init, bool krealloc)
+			bool init, bool keep_tag)
 {
-	/* Reuse the same tag for krealloc'ed objects. */
-	if (krealloc)
+	/*
+	 * 1. When an object is kmalloc()'ed, two hooks are called:
+	 *    kasan_slab_alloc() and kasan_kmalloc(). We assign the
+	 *    tag only in the first one.
+	 * 2. We reuse the same tag for krealloc'ed objects.
+	 */
+	if (keep_tag)
 		return get_tag(object);
 
 	/*
@@ -405,12 +410,6 @@ void * __must_check kasan_init_slab_obj(struct kmem_cache *cache,
 	return (void *)object;
 }
 
-void * __must_check kasan_slab_alloc(struct kmem_cache *cache, void *object,
-					gfp_t flags)
-{
-	return kasan_kmalloc(cache, object, cache->object_size, flags);
-}
-
 static inline bool shadow_invalid(u8 tag, s8 shadow_byte)
 {
 	if (IS_ENABLED(CONFIG_KASAN_GENERIC))
@@ -467,7 +466,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 }
 
 static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
-				size_t size, gfp_t flags, bool krealloc)
+				size_t size, gfp_t flags, bool keep_tag)
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
@@ -485,7 +484,7 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
 				KASAN_SHADOW_SCALE_SIZE);
 
 	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
-		tag = assign_tag(cache, object, false, krealloc);
+		tag = assign_tag(cache, object, false, keep_tag);
 
 	/* Tag is ignored in set_tag without CONFIG_KASAN_SW_TAGS */
 	kasan_unpoison_shadow(set_tag(object, tag), size);
@@ -498,10 +497,16 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
 	return set_tag(object, tag);
 }
 
+void * __must_check kasan_slab_alloc(struct kmem_cache *cache, void *object,
+					gfp_t flags)
+{
+	return __kasan_kmalloc(cache, object, cache->object_size, flags, false);
+}
+
 void * __must_check kasan_kmalloc(struct kmem_cache *cache, const void *object,
 				size_t size, gfp_t flags)
 {
-	return __kasan_kmalloc(cache, object, size, flags, false);
+	return __kasan_kmalloc(cache, object, size, flags, true);
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
-- 
2.20.1.791.gb4d0f1c61a-goog

