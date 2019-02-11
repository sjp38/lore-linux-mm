Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC466C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F068218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="AXw7e0VU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F068218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66A0A8E0175; Mon, 11 Feb 2019 17:00:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57B418E0165; Mon, 11 Feb 2019 17:00:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41A4D8E0175; Mon, 11 Feb 2019 17:00:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB3C38E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:09 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id t13so175042wrv.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:00:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/+CAbD8bU+nyd3L0sYTP0WbxN9sT6g9T2UAB46YxuA8=;
        b=hAoZMg+0MLM8FWykbK3feB+xOzEvsvyqbZ5cZrNMBfenoBVMVhRhln/8opRXRdcqC6
         w4qpgE2L+BBBTwhvY9AhlsajgsjkD95p4ZL9DGCpctuVg2nuefBI/55Ki0oP5BJghmHA
         uD8f/n+konEDT0R+aIaYQ64AbEce5P4BVsAwXAdimJMkGGeS4AJ/tGbC37IuqRAFHekr
         rBmqejmvfmLR8MDnQDjmE5ypRgjo4Bav+Z5bqpAzc6SMx02GJ0Z2Iv9sKj0A6DNrM4ZU
         vUEq8pdPR+Td2eZwNLrnQ1VTy3b9daF+ub0TSwdKFQQm6212lgkM3u58BsyeGOm9ApcI
         mHnw==
X-Gm-Message-State: AHQUAubM/K8ynFsHVcWMYxUOZvNq39UIgcV0Ak4xN5mVHhgzcX3vOY3+
	K7afkMHc5V5AlzKReMIlCX5X9ic1xN5qt3izkMi9LVp6FR/17/u0DDKShTlYzPDIv/lvX2RWiFy
	XqXhBZnMzcFgYTyyGOes2g9jIYOyc3XnnVJRLPlF7Tb+OKlF3LhsfsyEB8KHTSjjhP/UxiAyZaa
	F3IeYXoW7WoX6X8QakO6as57pclba+cd0Es2Lz2asiZpz5pkFc+s0MzgjZ3HVenLENb2wcTVEQd
	QS4ATgLAqbhVfPRZAhLhdmj/s6ugW1vzou48Vr+Au/xh04MT2kQe1J5QEYiGjEpseXJQrXoKhEI
	+CNDdtCw4GZ2AidBhFTiSQ/N87/stud5z/nqJsQg+siFHcip1/uFlS21X+khpnv4EOrIADIFx4v
	P
X-Received: by 2002:a1c:7016:: with SMTP id l22mr307688wmc.70.1549922409410;
        Mon, 11 Feb 2019 14:00:09 -0800 (PST)
X-Received: by 2002:a1c:7016:: with SMTP id l22mr307643wmc.70.1549922408565;
        Mon, 11 Feb 2019 14:00:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922408; cv=none;
        d=google.com; s=arc-20160816;
        b=meqXvfdZt5maPMYB5LQLOX3ckyVp5zr/ANjdQ5oPohCwjuALTyoKOA+LDmUjN9wDkR
         QiZbBAkb06/Hk6bmfUi98svVULiOQOPiBVdTfGgU3yzrfcvAqGylM0ugl3Zp6b/A5QbN
         2D2Ea7tif2bdJR4uskID5jYKNPpK8Nh+j7smFpQjybCQjevyw4A2348u5z0HE7knE8Nf
         KJU12g6QW7ka6UaspCvaLTxxIuD6yCeOeKrHfn/aGmDBLwcJjibsQcR+IE36OjX/5bGZ
         EXfEp3MXzUCQlGqurD01CgjeSvUZpvh0P8dRZSwOrW50j1Yft9GwK2Aw9gXj46iFiDLi
         lobw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/+CAbD8bU+nyd3L0sYTP0WbxN9sT6g9T2UAB46YxuA8=;
        b=eJJNPMKctI1DV3jvxm9wXDJ+JBak7XmzNuYturO3O2hugHck96MqWDNVQA4yZ5oxnB
         iawZB/Cxrw8Wj6ij6E32toCHlpCxd5DvwQ8dbyMoK3lGVbqLyr/OaxF3wN5luRLJrEbP
         ONmjLXvmBkPQje0xus4Bn8dTOm2SVEUgDzGjpeUqkkXgmoodwNM5jpaEWHszPTGMXTqg
         1c5DWJQB3SKgKL/t6SdDsvCmTps42+MSAlcKAEoNqne4mdLmT73VXgL2lcl82pNWBbOZ
         8mByJA0XrBkYVioRzi+WXm5DOasOMxwXVEY9LRLf/8V9u/hPmWNlJgexdSHwp5/kXfub
         Zl3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=AXw7e0VU;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor7017124wrx.39.2019.02.11.14.00.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:00:08 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=AXw7e0VU;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/+CAbD8bU+nyd3L0sYTP0WbxN9sT6g9T2UAB46YxuA8=;
        b=AXw7e0VUVwpxGIBaconhcN6hqrC4WQR4zPt8o0rYjlgynPJ6dGhpuRpD7+aAnAGkqn
         dKfMliiAoNqHNajceLpH3nZ/VwnE9iP8MwkrBmswHsu7N60/z3wXikIVui2Hf/L3bjVU
         rmkXHSaBgSZX+zs0yMP1i3+QHzOtBbNKruR1isCq1cYSSGdDyVjYXn4WRlBTvY6W+eIq
         xKGTI49OWsqkTTjeeWo2X/2xCbVq7p/jp8qnMO0aBqEWhAmXoWNEqSp9t6nbdJC+h9Pt
         +FTBq6sEkiVZ+9tpWtj5WBaTDMnEMuayhPLfyLBnWLIcikTGHPe4mqcefLqMxHmDkgzS
         CAtA==
X-Google-Smtp-Source: AHgI3Ibr24Su8y7sxS10natSgYZC4T4Yaa/HmavywUcKbRoFeE8GXeKiZeBTQW0K67qDQuE3IdbBbA==
X-Received: by 2002:adf:dd43:: with SMTP id u3mr240892wrm.259.1549922408030;
        Mon, 11 Feb 2019 14:00:08 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id c186sm762685wmf.34.2019.02.11.14.00.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:00:06 -0800 (PST)
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
Subject: [PATCH 5/5] kasan, slub: fix conflicts with CONFIG_SLAB_FREELIST_HARDENED
Date: Mon, 11 Feb 2019 22:59:54 +0100
Message-Id: <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
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

CONFIG_SLAB_FREELIST_HARDENED hashes freelist pointer with the address
of the object where the pointer gets stored. With tag based KASAN we don't
account for that when building freelist, as we call set_freepointer() with
the first argument untagged. This patch changes the code to properly
propagate tags throughout the loop.

Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ce874a5c9ee7..0d32f8d30752 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -303,11 +303,6 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 		__p < (__addr) + (__objects) * (__s)->size; \
 		__p += (__s)->size)
 
-#define for_each_object_idx(__p, __idx, __s, __addr, __objects) \
-	for (__p = fixup_red_left(__s, __addr), __idx = 1; \
-		__idx <= __objects; \
-		__p += (__s)->size, __idx++)
-
 /* Determine object index from a given position */
 static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
 {
@@ -1655,17 +1650,16 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	shuffle = shuffle_freelist(s, page);
 
 	if (!shuffle) {
-		for_each_object_idx(p, idx, s, start, page->objects) {
-			if (likely(idx < page->objects)) {
-				next = p + s->size;
-				next = setup_object(s, page, next);
-				set_freepointer(s, p, next);
-			} else
-				set_freepointer(s, p, NULL);
-		}
 		start = fixup_red_left(s, start);
 		start = setup_object(s, page, start);
 		page->freelist = start;
+		for (idx = 0, p = start; idx < page->objects - 1; idx++) {
+			next = p + s->size;
+			next = setup_object(s, page, next);
+			set_freepointer(s, p, next);
+			p = next;
+		}
+		set_freepointer(s, p, NULL);
 	}
 
 	page->inuse = page->objects;
-- 
2.20.1.791.gb4d0f1c61a-goog

