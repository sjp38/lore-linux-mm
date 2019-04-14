Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D3ABC282DA
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 09:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C058220850
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 09:15:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="EDAcwdlT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C058220850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D3B56B0003; Sun, 14 Apr 2019 05:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 084AC6B0005; Sun, 14 Apr 2019 05:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8EB76B0006; Sun, 14 Apr 2019 05:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A99386B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 05:15:31 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c7so9294955plo.8
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 02:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=vRRcEPYbxm8qxdiKICgsSV963r4N3P/UdEcjZU8l5DM=;
        b=TvQvVQJ/qBZ/VMkF4hiTPWTOBJZOlC5Deu8PNA1HrCojkX9bR2m6TpgX6dabBBPlI8
         nStJBVWAjllLm9giVi7ktJYVBdDJKCWELuIdBzwNrcSr3kq7S+G2MyaOc1bBk67TSOi2
         tq+6z21uc/4G+ZRPRSjsgir8Pb5mfpe0LdukZKVIZm8v8xGtJz3ZJPZX5qHgw0xe7OBP
         8buagnjLgdwISc6WTHyK8rAGKhrb/45+4QpxgZYjyAqXdT29uDJae0CSdhfwsxs22R8Y
         HUYlomINgwDHPqpl7QSy74Lold4jssr5fqA7UIj4ARBmrwYcFuOOIKn5QQ5Po+sgdUf+
         RuZA==
X-Gm-Message-State: APjAAAUjiwFMaKHDqeqKWrHlzdqC7rv33G7bTVJFBqDLZtSlC5Nh3qpw
	XlgI6mHBvEw7pgfNTs3iVi5OGB0N8SEWVDU/26Ht8aYwpUwQhJuzmHCo2Jke8UWPD4+LgsApFr7
	Yy5d5pP7y3v1btBLFP/T5s1/GJO5w9ondQTkuzArJbjFT6t0vbqmAZZJCpsEQzpHSEQ==
X-Received: by 2002:a65:6108:: with SMTP id z8mr63793768pgu.106.1555233330924;
        Sun, 14 Apr 2019 02:15:30 -0700 (PDT)
X-Received: by 2002:a65:6108:: with SMTP id z8mr63793646pgu.106.1555233329119;
        Sun, 14 Apr 2019 02:15:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555233329; cv=none;
        d=google.com; s=arc-20160816;
        b=A33zaYxvaaC4O0VNkAk6LNMX4WzLMlw0ss7J87HYt6kKgEBIpD4Q6LGHp28yhfNArv
         WPWNez5PtIzAS7y1KjV2ZKkl9VPWoTblvQ/RX5UnZitFpVEUwYJjclNhLbFw12sh7rnZ
         lwqkZ4oxF6+mBTDWPSY2pnO+ArnBNUuUbMUm51GQzPLfu7p/FvVmmOXZbOdN06BVDnUz
         fzcc9wD1ML79xP/yXl3M0sWx/tqzU8Emv/NxUqqiEs+gI4b6rCseeN/pCOI5ylwPFl6x
         515cRWVvxsXEAF8aFmCzv4RkpNLQbxre34AA+Xhkjs//ytOSvISWvwdXdgjmUXw13YN6
         xx0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=vRRcEPYbxm8qxdiKICgsSV963r4N3P/UdEcjZU8l5DM=;
        b=YKCS2tIWTXcNz1ug9nzDgeddmRUtLyO23Ri8ofpqMd9H8sT6Tz4iNLc0wWDfOv6NFi
         q+GT0FdXCCKRx0pvvBey/47pN8x9kzCyvKCQcaDU0PnewVV8Usp72PrXY/bXpVonuQZz
         5Wl0nEwMDaQk3GDgabhP/812OXX/Mns6FENfzYMlqG6zqNZWsfNE7vwzTEltn5L3ojpt
         HU5S/yOHgLmEcn6EUVe/E7I3s/D+mK98uFSU1H1ORzEbo/pf+Hx9OZSy1HEue/IjFz/X
         mKMQwLktXDKIAN7ekNnZ08M0wDcSHmmwybbB9nln67bbC5UyIwFnUY3GS4+QSzSknDf4
         QNNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=EDAcwdlT;
       spf=pass (google.com: domain of shyam.saini@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shyam.saini@amarulasolutions.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v14sor58304138plo.31.2019.04.14.02.15.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Apr 2019 02:15:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of shyam.saini@amarulasolutions.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=EDAcwdlT;
       spf=pass (google.com: domain of shyam.saini@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shyam.saini@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=vRRcEPYbxm8qxdiKICgsSV963r4N3P/UdEcjZU8l5DM=;
        b=EDAcwdlTOD3tmFgmgNd00TgyVBPtnAZVRkkbgLXBc2FtYTrVDzz3hfJSnPPPZ/Fapd
         TG7ubF33dl6SBe4ePN2JyRcS2y1iCMhiiPKWZ3kz1aLcf57AumexE/QXKfNDWOQHNsfV
         2kAFPe3tJttHG+S8SyZJSi8ozL67oRK4dF45w=
X-Google-Smtp-Source: APXvYqxKDiWNAV2GbIV2osvJzhMMguczbch06STOXR2wI2j8NAN+F5G3UR6KPg4JgzhzkDUgVHJ/FA==
X-Received: by 2002:a17:902:7483:: with SMTP id h3mr13348776pll.211.1555233328499;
        Sun, 14 Apr 2019 02:15:28 -0700 (PDT)
Received: from localhost.localdomain ([42.111.19.105])
        by smtp.googlemail.com with ESMTPSA id g10sm31344767pgq.54.2019.04.14.02.15.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 02:15:27 -0700 (PDT)
From: Shyam Saini <shyam.saini@amarulasolutions.com>
To: kernel-hardening@lists.openwall.com
Cc: linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	keescook@chromium.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	intel-gvt-dev@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	netdev@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	devel@lists.orangefs.org,
	linux-mm@kvack.org,
	linux-sctp@vger.kernel.org,
	bpf@vger.kernel.org,
	kvm@vger.kernel.org,
	mayhs11saini@gmail.com,
	Shyam Saini <shyam.saini@amarulasolutions.com>
Subject: [PATCH 1/2] include: linux: Regularise the use of FIELD_SIZEOF macro
Date: Sun, 14 Apr 2019 14:44:51 +0530
Message-Id: <20190414091452.22275-1-shyam.saini@amarulasolutions.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, there are 3 different macros, namely sizeof_field, SIZEOF_FIELD
and FIELD_SIZEOF which are used to calculate the size of a member of
structure, so to bring uniformity in entire kernel source tree lets use
FIELD_SIZEOF and replace all occurrences of other two macros with this.

For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
tools/testing/selftests/bpf/bpf_util.h and remove its defination from
include/linux/kernel.h

Signed-off-by: Shyam Saini <shyam.saini@amarulasolutions.com>
---
 arch/arm64/include/asm/processor.h                 | 10 +++++-----
 arch/mips/cavium-octeon/executive/cvmx-bootmem.c   |  2 +-
 drivers/gpu/drm/i915/gvt/scheduler.c               |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c |  4 ++--
 fs/befs/linuxvfs.c                                 |  2 +-
 fs/ext2/super.c                                    |  2 +-
 fs/ext4/super.c                                    |  2 +-
 fs/freevxfs/vxfs_super.c                           |  2 +-
 fs/orangefs/super.c                                |  2 +-
 fs/ufs/super.c                                     |  2 +-
 include/linux/kernel.h                             |  9 ---------
 include/linux/slab.h                               |  2 +-
 include/linux/stddef.h                             | 11 ++++++++++-
 kernel/fork.c                                      |  2 +-
 kernel/utsname.c                                   |  2 +-
 net/caif/caif_socket.c                             |  2 +-
 net/core/skbuff.c                                  |  2 +-
 net/ipv4/raw.c                                     |  2 +-
 net/ipv6/raw.c                                     |  2 +-
 net/sctp/socket.c                                  |  4 ++--
 tools/testing/selftests/bpf/bpf_util.h             | 11 ++++++++++-
 virt/kvm/kvm_main.c                                |  2 +-
 22 files changed, 45 insertions(+), 36 deletions(-)

diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 5d9ce62bdebd..79141eb2c673 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -156,13 +156,13 @@ static inline void arch_thread_struct_whitelist(unsigned long *offset,
 						unsigned long *size)
 {
 	/* Verify that there is no padding among the whitelisted fields: */
-	BUILD_BUG_ON(sizeof_field(struct thread_struct, uw) !=
-		     sizeof_field(struct thread_struct, uw.tp_value) +
-		     sizeof_field(struct thread_struct, uw.tp2_value) +
-		     sizeof_field(struct thread_struct, uw.fpsimd_state));
+	BUILD_BUG_ON(FIELD_SIZEOF(struct thread_struct, uw) !=
+		     FIELD_SIZEOF(struct thread_struct, uw.tp_value) +
+		     FIELD_SIZEOF(struct thread_struct, uw.tp2_value) +
+		     FIELD_SIZEOF(struct thread_struct, uw.fpsimd_state));
 
 	*offset = offsetof(struct thread_struct, uw);
-	*size = sizeof_field(struct thread_struct, uw);
+	*size = FIELD_SIZEOF(struct thread_struct, uw);
 }
 
 #ifdef CONFIG_COMPAT
diff --git a/arch/mips/cavium-octeon/executive/cvmx-bootmem.c b/arch/mips/cavium-octeon/executive/cvmx-bootmem.c
index ba8f82a29a81..fc754d155002 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-bootmem.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-bootmem.c
@@ -65,7 +65,7 @@ static struct cvmx_bootmem_desc *cvmx_bootmem_desc;
 #define CVMX_BOOTMEM_NAMED_GET_FIELD(addr, field)			\
 	__cvmx_bootmem_desc_get(addr,					\
 		offsetof(struct cvmx_bootmem_named_block_desc, field),	\
-		SIZEOF_FIELD(struct cvmx_bootmem_named_block_desc, field))
+		FIELD_SIZEOF(struct cvmx_bootmem_named_block_desc, field))
 
 /**
  * This function is the implementation of the get macros defined
diff --git a/drivers/gpu/drm/i915/gvt/scheduler.c b/drivers/gpu/drm/i915/gvt/scheduler.c
index 05b953793316..6b344ff7c1f8 100644
--- a/drivers/gpu/drm/i915/gvt/scheduler.c
+++ b/drivers/gpu/drm/i915/gvt/scheduler.c
@@ -1206,7 +1206,7 @@ int intel_vgpu_setup_submission(struct intel_vgpu *vgpu)
 						  sizeof(struct intel_vgpu_workload), 0,
 						  SLAB_HWCACHE_ALIGN,
 						  offsetof(struct intel_vgpu_workload, rb_tail),
-						  sizeof_field(struct intel_vgpu_workload, rb_tail),
+						  FIELD_SIZEOF(struct intel_vgpu_workload, rb_tail),
 						  NULL);
 
 	if (!s->workloads) {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
index 46baf3b44309..c0447bf07fbb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
@@ -49,13 +49,13 @@ struct mlxsw_sp_fid_8021d {
 };
 
 static const struct rhashtable_params mlxsw_sp_fid_ht_params = {
-	.key_len = sizeof_field(struct mlxsw_sp_fid, fid_index),
+	.key_len = FIELD_SIZEOF(struct mlxsw_sp_fid, fid_index),
 	.key_offset = offsetof(struct mlxsw_sp_fid, fid_index),
 	.head_offset = offsetof(struct mlxsw_sp_fid, ht_node),
 };
 
 static const struct rhashtable_params mlxsw_sp_fid_vni_ht_params = {
-	.key_len = sizeof_field(struct mlxsw_sp_fid, vni),
+	.key_len = FIELD_SIZEOF(struct mlxsw_sp_fid, vni),
 	.key_offset = offsetof(struct mlxsw_sp_fid, vni),
 	.head_offset = offsetof(struct mlxsw_sp_fid, vni_ht_node),
 };
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 4700b4534439..0b179bfa481c 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -443,7 +443,7 @@ befs_init_inodecache(void)
 					SLAB_ACCOUNT),
 				offsetof(struct befs_inode_info,
 					i_data.symlink),
-				sizeof_field(struct befs_inode_info,
+				FIELD_SIZEOF(struct befs_inode_info,
 					i_data.symlink),
 				init_once);
 	if (befs_inode_cachep == NULL)
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 0128010a0874..7a84e1445aa1 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -225,7 +225,7 @@ static int __init init_inodecache(void)
 				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
 					SLAB_ACCOUNT),
 				offsetof(struct ext2_inode_info, i_data),
-				sizeof_field(struct ext2_inode_info, i_data),
+				FIELD_SIZEOF(struct ext2_inode_info, i_data),
 				init_once);
 	if (ext2_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 6ed4eb81e674..651bebe24b0e 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1145,7 +1145,7 @@ static int __init init_inodecache(void)
 				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
 					SLAB_ACCOUNT),
 				offsetof(struct ext4_inode_info, i_data),
-				sizeof_field(struct ext4_inode_info, i_data),
+				FIELD_SIZEOF(struct ext4_inode_info, i_data),
 				init_once);
 	if (ext4_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/freevxfs/vxfs_super.c b/fs/freevxfs/vxfs_super.c
index 48b24bb50d02..d6c666dd0cb8 100644
--- a/fs/freevxfs/vxfs_super.c
+++ b/fs/freevxfs/vxfs_super.c
@@ -336,7 +336,7 @@ vxfs_init(void)
 			sizeof(struct vxfs_inode_info), 0,
 			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
 			offsetof(struct vxfs_inode_info, vii_immed.vi_immed),
-			sizeof_field(struct vxfs_inode_info,
+			FIELD_SIZEOF(struct vxfs_inode_info,
 				vii_immed.vi_immed),
 			NULL);
 	if (!vxfs_inode_cachep)
diff --git a/fs/orangefs/super.c b/fs/orangefs/super.c
index dfaee90d30bd..902294097236 100644
--- a/fs/orangefs/super.c
+++ b/fs/orangefs/super.c
@@ -623,7 +623,7 @@ int orangefs_inode_cache_initialize(void)
 					ORANGEFS_CACHE_CREATE_FLAGS,
 					offsetof(struct orangefs_inode_s,
 						link_target),
-					sizeof_field(struct orangefs_inode_s,
+					FIELD_SIZEOF(struct orangefs_inode_s,
 						link_target),
 					orangefs_inode_cache_ctor);
 
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index a4e07e910f1b..560d9295f725 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1474,7 +1474,7 @@ static int __init init_inodecache(void)
 				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
 					SLAB_ACCOUNT),
 				offsetof(struct ufs_inode_info, i_u1.i_symlink),
-				sizeof_field(struct ufs_inode_info,
+				FIELD_SIZEOF(struct ufs_inode_info,
 					i_u1.i_symlink),
 				init_once);
 	if (ufs_inode_cachep == NULL)
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 34a5036debd3..000455d78383 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -78,15 +78,6 @@
  */
 #define round_down(x, y) ((x) & ~__round_mask(x, y))
 
-/**
- * FIELD_SIZEOF - get the size of a struct's field
- * @t: the target struct
- * @f: the target struct's field
- * Return: the size of @f in the struct definition without having a
- * declared instance of @t.
- */
-#define FIELD_SIZEOF(t, f) (sizeof(((t*)0)->f))
-
 #define DIV_ROUND_UP __KERNEL_DIV_ROUND_UP
 
 #define DIV_ROUND_DOWN_ULL(ll, d) \
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..8bdfdd389b37 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -175,7 +175,7 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *);
 			sizeof(struct __struct),			\
 			__alignof__(struct __struct), (__flags),	\
 			offsetof(struct __struct, __field),		\
-			sizeof_field(struct __struct, __field), NULL)
+			FIELD_SIZEOF(struct __struct, __field), NULL)
 
 /*
  * Common kmalloc functions provided by all allocators
diff --git a/include/linux/stddef.h b/include/linux/stddef.h
index 998a4ba28eba..63f2302bc406 100644
--- a/include/linux/stddef.h
+++ b/include/linux/stddef.h
@@ -20,6 +20,15 @@ enum {
 #endif
 
 /**
+ * FIELD_SIZEOF - get the size of a struct's field
+ * @t: the target struct
+ * @f: the target struct's field
+ * Return: the size of @f in the struct definition without having a
+ * declared instance of @t.
+ */
+#define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))
+
+/**
  * sizeof_field(TYPE, MEMBER)
  *
  * @TYPE: The structure containing the field of interest
@@ -34,6 +43,6 @@ enum {
  * @MEMBER: The member within the structure to get the end offset of
  */
 #define offsetofend(TYPE, MEMBER) \
-	(offsetof(TYPE, MEMBER)	+ sizeof_field(TYPE, MEMBER))
+	(offsetof(TYPE, MEMBER)	+ FIELD_SIZEOF(TYPE, MEMBER))
 
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..1890a487e516 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2410,7 +2410,7 @@ void __init proc_caches_init(void)
 			mm_size, ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT,
 			offsetof(struct mm_struct, saved_auxv),
-			sizeof_field(struct mm_struct, saved_auxv),
+			FIELD_SIZEOF(struct mm_struct, saved_auxv),
 			NULL);
 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
 	mmap_init();
diff --git a/kernel/utsname.c b/kernel/utsname.c
index dcd6be1996fe..3850e364240e 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -178,6 +178,6 @@ void __init uts_ns_init(void)
 			"uts_namespace", sizeof(struct uts_namespace), 0,
 			SLAB_PANIC|SLAB_ACCOUNT,
 			offsetof(struct uts_namespace, name),
-			sizeof_field(struct uts_namespace, name),
+			FIELD_SIZEOF(struct uts_namespace, name),
 			NULL);
 }
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 416717c57cd1..88a7d109d89c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1033,7 +1033,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 		.owner = THIS_MODULE,
 		.obj_size = sizeof(struct caifsock),
 		.useroffset = offsetof(struct caifsock, conn_req.param),
-		.usersize = sizeof_field(struct caifsock, conn_req.param)
+		.usersize = FIELD_SIZEOF(struct caifsock, conn_req.param)
 	};
 
 	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ef2cd5712098..f4a0af390ab7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3951,7 +3951,7 @@ void __init skb_init(void)
 					      0,
 					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					      offsetof(struct sk_buff, cb),
-					      sizeof_field(struct sk_buff, cb),
+					      FIELD_SIZEOF(struct sk_buff, cb),
 					      NULL);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						sizeof(struct sk_buff_fclones),
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index c55a5432cf37..4d1db4b252f5 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -981,7 +981,7 @@ struct proto raw_prot = {
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw_sock),
 	.useroffset	   = offsetof(struct raw_sock, filter),
-	.usersize	   = sizeof_field(struct raw_sock, filter),
+	.usersize	   = FIELD_SIZEOF(struct raw_sock, filter),
 	.h.raw_hash	   = &raw_v4_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5a426226c762..c8fc69769762 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1283,7 +1283,7 @@ struct proto rawv6_prot = {
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw6_sock),
 	.useroffset	   = offsetof(struct raw6_sock, filter),
-	.usersize	   = sizeof_field(struct raw6_sock, filter),
+	.usersize	   = FIELD_SIZEOF(struct raw6_sock, filter),
 	.h.raw_hash	   = &raw_v6_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_rawv6_setsockopt,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9874e60c9b0d..80fbc6191d0a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -9385,7 +9385,7 @@ struct proto sctp_prot = {
 	.useroffset  =  offsetof(struct sctp_sock, subscribe),
 	.usersize    =  offsetof(struct sctp_sock, initmsg) -
 				offsetof(struct sctp_sock, subscribe) +
-				sizeof_field(struct sctp_sock, initmsg),
+				FIELD_SIZEOF(struct sctp_sock, initmsg),
 	.sysctl_mem  =  sysctl_sctp_mem,
 	.sysctl_rmem =  sysctl_sctp_rmem,
 	.sysctl_wmem =  sysctl_sctp_wmem,
@@ -9427,7 +9427,7 @@ struct proto sctpv6_prot = {
 	.useroffset	= offsetof(struct sctp6_sock, sctp.subscribe),
 	.usersize	= offsetof(struct sctp6_sock, sctp.initmsg) -
 				offsetof(struct sctp6_sock, sctp.subscribe) +
-				sizeof_field(struct sctp6_sock, sctp.initmsg),
+				FIELD_SIZEOF(struct sctp6_sock, sctp.initmsg),
 	.sysctl_mem	= sysctl_sctp_mem,
 	.sysctl_rmem	= sysctl_sctp_rmem,
 	.sysctl_wmem	= sysctl_sctp_wmem,
diff --git a/tools/testing/selftests/bpf/bpf_util.h b/tools/testing/selftests/bpf/bpf_util.h
index a29206ebbd13..2e90a4315b55 100644
--- a/tools/testing/selftests/bpf/bpf_util.h
+++ b/tools/testing/selftests/bpf/bpf_util.h
@@ -58,13 +58,22 @@ static inline unsigned int bpf_num_possible_cpus(void)
 # define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif
 
+/*
+ * FIELD_SIZEOF - get the size of a struct's field
+ * @t: the target struct
+ * @f: the target struct's field
+ * Return: the size of @f in the struct definition without having a
+ * declared instance of @t.
+ */
+#define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))
+
 #ifndef sizeof_field
 #define sizeof_field(TYPE, MEMBER) sizeof((((TYPE *)0)->MEMBER))
 #endif
 
 #ifndef offsetofend
 #define offsetofend(TYPE, MEMBER) \
-	(offsetof(TYPE, MEMBER)	+ sizeof_field(TYPE, MEMBER))
+	(offsetof(TYPE, MEMBER)	+ FIELD_SIZEOF(TYPE, MEMBER))
 #endif
 
 #endif /* __BPF_UTIL__ */
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 55fe8e20d8fd..2577feaf7c38 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -4181,7 +4181,7 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
 		kmem_cache_create_usercopy("kvm_vcpu", vcpu_size, vcpu_align,
 					   SLAB_ACCOUNT,
 					   offsetof(struct kvm_vcpu, arch),
-					   sizeof_field(struct kvm_vcpu, arch),
+					   FIELD_SIZEOF(struct kvm_vcpu, arch),
 					   NULL);
 	if (!kvm_vcpu_cache) {
 		r = -ENOMEM;
-- 
2.11.0

