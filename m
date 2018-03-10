Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0076B000A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:21:58 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id r33so3627593qkh.2
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:21:58 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j60si2118100qtb.26.2018.03.09.19.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:57 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 04/13] drm/nouveau/mmu/gp100: allow gcc/tex to generate replayable faults
Date: Fri,  9 Mar 2018 22:21:32 -0500
Message-Id: <20180310032141.6096-5-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: Ben Skeggs <bskeggs@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: Ben Skeggs <bskeggs@redhat.com>

Signed-off-by: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c
index 059fafe0e771..8752d9ce4af0 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c
@@ -315,7 +315,10 @@ gp100_vmm_flush(struct nvkm_vmm *vmm, int depth)
 int
 gp100_vmm_join(struct nvkm_vmm *vmm, struct nvkm_memory *inst)
 {
-	const u64 base = BIT_ULL(10) /* VER2 */ | BIT_ULL(11); /* 64KiB */
+	const u64 base = BIT_ULL(4) /* FAULT_REPLAY_TEX */ |
+			 BIT_ULL(5) /* FAULT_REPLAY_GCC */ |
+			 BIT_ULL(10) /* VER2 */ |
+			 BIT_ULL(11) /* 64KiB */;
 	return gf100_vmm_join_(vmm, inst, base);
 }
 
-- 
2.14.3
