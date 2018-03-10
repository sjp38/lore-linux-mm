Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F33476B0006
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:21:57 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id y7so3589018qkd.10
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:21:57 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p39si2234911qta.111.2018.03.09.19.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:57 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 02/13] drm/nouveau/core/memory: add some useful accessor macros
Date: Fri,  9 Mar 2018 22:21:30 -0500
Message-Id: <20180310032141.6096-3-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Adds support for 64-bits read.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/nouveau/include/nvkm/core/memory.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/gpu/drm/nouveau/include/nvkm/core/memory.h b/drivers/gpu/drm/nouveau/include/nvkm/core/memory.h
index 05f505de0075..d1a886c4d2d9 100644
--- a/drivers/gpu/drm/nouveau/include/nvkm/core/memory.h
+++ b/drivers/gpu/drm/nouveau/include/nvkm/core/memory.h
@@ -82,6 +82,14 @@ void nvkm_memory_tags_put(struct nvkm_memory *, struct nvkm_device *,
 	nvkm_wo32((o), __a + 4, upper_32_bits(__d));                           \
 } while(0)
 
+#define nvkm_ro64(o,a) ({                                                      \
+	u64 _data;                                                             \
+	_data = nvkm_ro32((o), (a) + 4);                                       \
+	_data = _data << 32;                                                   \
+	_data |= nvkm_ro32((o), (a) + 0);                                      \
+	_data;                                                                 \
+})
+
 #define nvkm_fill(t,s,o,a,d,c) do {                                            \
 	u64 _a = (a), _c = (c), _d = (d), _o = _a >> s, _s = _c << s;          \
 	u##t __iomem *_m = nvkm_kmap(o);                                       \
-- 
2.14.3
