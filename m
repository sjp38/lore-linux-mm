Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA50DC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77A87222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kjGmPdlV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77A87222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09ACB8E0005; Wed, 13 Feb 2019 08:58:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0245A8E0004; Wed, 13 Feb 2019 08:58:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D96D78E0005; Wed, 13 Feb 2019 08:58:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6FC8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:40 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e14so893972wrt.12
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9CMPZjRzPxA9yWJGkQniQIkHzZh/Nj3CjJ78bKTFu6c=;
        b=ZUHw0Sf36YTGKvYyp1GDn8E2vb4SeDlMfI61s6EQcflLnxnF5GdckHlemlvJZT+w4x
         7ph4JG4izzIfdDR7OvTKKQoWyW5RKyt8NRVP4WIWmHtA95wgkCLBIwFS0AbndmVb9/pd
         DAisVUwT2LlJLFNEbBB8RWeyGq8GxJvNS7qipoeBNmwK3ex41MTLxLlamEhAHD9nMXOp
         C3Q50gvzlVhMsvQ9rzQBAJEhGWO7cY9Wcc380qSId0BJtRq4rKyWO1pJAI5uX3b+p0PL
         dH4OLNB8Fq7Rrhtmvlng3LieV/z4nm5xbawfRlTua+HC24TEnvDe2TBYFmrVVkMCqTnG
         PHOg==
X-Gm-Message-State: AHQUAubH8Be8cnTNrxIOs1hFhKdvvXJkfTaSmoUDbRgxobCYZ4J3VQuw
	X+HDNJgkG339AHc73Pd8FAhL85MdiGUOFFM+ambzVo+3z6kPwSZNp4WTZDTAsLUmS6iX3MqLXpj
	TbiCJNG3G9vEAo6RUZrlgEhSklioT870FV5jAnxOc4BGpV6UXJ0wiMDU0lH+z28ILhtt2Bk7vgt
	c+7ThKRayWN8eSsmGXsCvC3CXjpbbnOwp7b4o490N9vS515YUIDJSQA3IZ9+VWIbB2gNf6Y4B70
	QDWvl6lE3Iz1Msx2j4jOytkDAqZ2Q85R1is3FSMtDNBkH4Cs09D4zjHGFNtRZaAb1Knt0D8XNhN
	NP8LK9lGYIOvR0XNE7bdUV0SvDEBzi+aoQ/Jn8A4DTlgmLjAzIIik1T03kcX0qwVnyG4169aHJb
	w
X-Received: by 2002:adf:ba8e:: with SMTP id p14mr519693wrg.230.1550066319942;
        Wed, 13 Feb 2019 05:58:39 -0800 (PST)
X-Received: by 2002:adf:ba8e:: with SMTP id p14mr519636wrg.230.1550066318903;
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066318; cv=none;
        d=google.com; s=arc-20160816;
        b=lwO/TUmTiF7+LmPrhYZZAu8wh9wuNLJKl0ymxG1heiT1RLLaCHT9IGYWueJ8aoI9Ff
         Sl41S84hDeVbyeO0eLwdpthe0X5O512jdcU8jDx9VZMBsvci1heL/PEeC78XtOXw/Z53
         UtqWkkW6JZuB0zWNvly3Ug/1mrux3jTX4ZMhNevVgyV48iHDW5e9En1z4OGtSqVsKko2
         hpyuX/loOudth3YWCZVex+SIGjw5G1kg0WVqSlPVT6gj/+iec6yTnaRr+xZOeZ727/SG
         1dS/yCUYvP7ebwCZHDwaDqKVMJGrGVBnbAq8XK9susso4dgEB+v5hBlOtJndCyP1WVra
         mGtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9CMPZjRzPxA9yWJGkQniQIkHzZh/Nj3CjJ78bKTFu6c=;
        b=a+5EtBmDjiNhoC/L631XP5gwI6fJRPFlRLnaPsGIPjFhceBA3TD527+GCdjLc2kKGy
         YmgUM2GwDLMBC4IIYVy529x8OEI4/oMHV4dxuiyUBZEnbxwvGELliF9jI8iVNn1v/e5a
         2HdVlRT5czSawiWH4FrX81xjKlxbDcaSl919OclFlAdkUrRtJBYDywkVWSO1unpBzGrk
         Dvx1JeGLYMywy2QOzDCBFSDMyk6YSips2/l6HQlkcWAATnbm7Fl5FK33yt678q6BSF+n
         ALiqn0ZfGZutm01dtgT+pwvl1kCgTZ4oc97HVSIdaOFEGJuf7BBBaiWb8I0M6hs583wf
         XTTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kjGmPdlV;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor10762748wrb.12.2019.02.13.05.58.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kjGmPdlV;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=9CMPZjRzPxA9yWJGkQniQIkHzZh/Nj3CjJ78bKTFu6c=;
        b=kjGmPdlVp+EE4yXdF9V3m6/2pdOxIjI9TduQHD7wABfQbumO8w8jJZdrEMDwclarVk
         iY0wzGb7Ynkr3XDwqbdfc68tu241EJwzZYcn574KEMW6H2Ena9s7bPizAO1iE1ape44f
         SbMHhf6qkqVNBoBSnoFxtmEXkrwxA2hsftnxvbjJRufiTDfsRNiZToeLWX/BTEAm7MIc
         gVgL6t0qdYp+zmRLiNvcT+c2K0u+y32Fv7D52wNM4/tWi34dFOlgb+1paUdGEsVH5Lzm
         fY6zoUWLYU5VWoaucELpS87NkXcA4DSD3g1hgc4wezyVoTnt6RNGf0GuJ8GGoD/qApT/
         uhEA==
X-Google-Smtp-Source: AHgI3IZeu8tyGHdGBePmSzE7Ptbmd1qACcvY/ml8RA3mou9xZXpuJmWZsOr8DOL9M1p61Emj+W1b7A==
X-Received: by 2002:adf:f845:: with SMTP id d5mr551808wrq.113.1550066318266;
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id v9sm11195866wrt.82.2019.02.13.05.58.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:58:36 -0800 (PST)
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
Subject: [PATCH v2 1/5] kasan: fix assigning tags twice
Date: Wed, 13 Feb 2019 14:58:26 +0100
Message-Id: <ce8c6431da735aa7ec051fd6497153df690eb021.1550066133.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
In-Reply-To: <cover.1550066133.git.andreyknvl@google.com>
References: <cover.1550066133.git.andreyknvl@google.com>
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

