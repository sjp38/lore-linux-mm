Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00642C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:23:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5EBC223F9
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:23:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ak/IUFJh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5EBC223F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D5B66B02A1; Tue, 16 Apr 2019 10:23:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 386876B02A2; Tue, 16 Apr 2019 10:23:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 274D56B02A3; Tue, 16 Apr 2019 10:23:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 062026B02A1
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:23:16 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n10so19525838qtk.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:23:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=v5zT/Zu265n7fMd2y+GkEVbND9utnsLCgOxsFe2ldPs=;
        b=ixI3YcK+ylaWA8q5eA1l/0d03B+lfAcsZsez10DkoqhkfxYrP34xT+IsYAVabWY16G
         luyD8oGCD7udsCjO9vAjtRNsRkZ5wnlUoHe/zC/CSHIiRV1S2r3TNDw04elzaKYW4+d/
         XCxwqi24Z737l9+QgB31TJnvH0jMb6F531GsXO9MCh8QTaAU84TKwPp9MxThO6fuFMUQ
         GlLOFJd0wbnjfZnoKiGwOOlVenS/PAIrRuKkxgZbo5/Wwv0ZdWJFr4qhZmWntl2DmoBP
         ChVj+n3cftSWmOcNFA0bh+9zTT/3yo9LR0FAnwWyG/5OBhUtqoDKQ62xll/uTjNv9S5V
         OU+Q==
X-Gm-Message-State: APjAAAWaqAFjzGV/Zrd1rXCYBJs9cH1MTE53VYyCQU01UdVLcfCbPL49
	nprrLdmXqcfiLxunnUXiF9Bmp7jbU1Rajh/eB7UGcpG3YIFacBH7aHpqI1hacedXsDfJdQi42M3
	0Spv5lWI/huQlYWR1gBsfWVydpHjcHy3xt6LwX3ddA285FUSdSjkHkYF316Ixo9SOZw==
X-Received: by 2002:ac8:298d:: with SMTP id 13mr67960410qts.174.1555424595794;
        Tue, 16 Apr 2019 07:23:15 -0700 (PDT)
X-Received: by 2002:ac8:298d:: with SMTP id 13mr67960183qts.174.1555424593291;
        Tue, 16 Apr 2019 07:23:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555424593; cv=none;
        d=google.com; s=arc-20160816;
        b=Am4hqQBfnRtt72kn/rz3tkc+rMM2chHIaylCgCslSmYzO7Cl2MLNHeMpIWwWDLaQsn
         uqu8tYhOLZ3D7eEGzWLWw2p2NtdCF/9CZ205oYGAYZKwe3nqOAr6sltTETgF41cTguks
         fo6dt//d0P9lBcb2CrV2TlVKDBprucPoc+kPmTOHDyXunQzzKECHf+B9lhnd0rX746Wi
         8K0sFnSYE4L2JjQr5HDdBqJ3oyRRzdJ6z0ZjcN1/CFGMVTzN0sQ48J8aFQHRNaBvZ3Tj
         k2Yp9/6/DDn8xi25uay0+a2KeXqYceFI4zGPPIjxvUCftdVURYtgADHXIUx8iySlAcaW
         EuQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=v5zT/Zu265n7fMd2y+GkEVbND9utnsLCgOxsFe2ldPs=;
        b=CF661SuD81CgY/xtuqG7f6UT+HIZa8O6/6KbSfcj6Wtg0JyXJKAISTa1zik7HY0sXm
         0cHmGJ+BtHb6yFmFefP3/97tsgr1VUywGa3/AQvBZz5z0BwRgTSj3Wu+ZbMTaVXFh6fH
         JlyzetBJtjbNPtyAZfbGA2Qz4U8ZkOzP2HOI3+Wekc0DAOn7UrV0WfeK1WpRTN+7hTHa
         CI9iTUkE5basdUSKuCCQRVb/z/GVOacRIGBjuO83NorxfUXuLr+bpWQffnAIcaIGJn+X
         oD6ebRGeuCCZ/XBfc/zsXVqMqIHgrd0fOL1Qngc30c1yu04rtHW39Ij/bCcZ0A69R/bi
         iacg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="ak/IUFJh";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c20sor41556529qtg.20.2019.04.16.07.23.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 07:23:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="ak/IUFJh";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=v5zT/Zu265n7fMd2y+GkEVbND9utnsLCgOxsFe2ldPs=;
        b=ak/IUFJhX4m++/VPO8H0CMl8nCkDgVWzzlFupD4H/IHKLfXek/EYspaXR7v4OhTQ7V
         ibBOI/icPQBDl9xrZaq3oA2CN+iJft+uC25xd7sCxSX3+DHFQaPpO/ar3J6fV4wBXc5g
         y8xZfebMKpcv0ztBnHqxcD/EnPXqndL8kLnPTSBs5ZaoDk3Jgvq0OGvOYs0yLmniZL49
         uCQ3MZQFRnE+DYbN5x1YbpvoVYg12SPaDPqs5FGgw6MP+LR94c1oDNB3cAOHjSDULVll
         54pQV/6R6xwB5QTGQ/XyNAlkQxXTwPEk6I8BBxwmaSzLpaekYy5ZBgBiAsOrbmF7K6/z
         0mug==
X-Google-Smtp-Source: APXvYqx26QteTZ52Wy2B/3wChpP64k1AgWRy8FQu7Hqo90Lx9kjjxFRruTMBTk+71Eh+hbeQSwJn2A==
X-Received: by 2002:ac8:3fbc:: with SMTP id d57mr63710484qtk.96.1555424592962;
        Tue, 16 Apr 2019 07:23:12 -0700 (PDT)
Received: from ovpn-120-81.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d17sm24693234qko.93.2019.04.16.07.23.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 07:23:11 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	luto@kernel.org,
	jpoimboe@redhat.com,
	sean.j.christopherson@intel.com,
	penberg@kernel.org,
	rientjes@google.com,
	tglx@linutronix.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: remove store_stackinfo()
Date: Tue, 16 Apr 2019 10:22:57 -0400
Message-Id: <20190416142258.18694-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

store_stackinfo() does not seem used in actual SLAB debugging.
Potentially, it could be added to check_poison_obj() to provide more
information, but this seems like an overkill due to the declining
popularity of the SLAB, so just remove it instead.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 48 ++++++------------------------------------------
 1 file changed, 6 insertions(+), 42 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3e1b7ff0360c..20f318f4f56e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1467,53 +1467,17 @@ static bool is_debug_pagealloc_cache(struct kmem_cache *cachep)
 }
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
-static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
-			    unsigned long caller)
-{
-	int size = cachep->object_size;
-
-	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
-
-	if (size < 5 * sizeof(unsigned long))
-		return;
-
-	*addr++ = 0x12345678;
-	*addr++ = caller;
-	*addr++ = smp_processor_id();
-	size -= 3 * sizeof(unsigned long);
-	{
-		unsigned long *sptr = &caller;
-		unsigned long svalue;
-
-		while (!kstack_end(sptr)) {
-			svalue = *sptr++;
-			if (kernel_text_address(svalue)) {
-				*addr++ = svalue;
-				size -= sizeof(unsigned long);
-				if (size <= sizeof(unsigned long))
-					break;
-			}
-		}
-
-	}
-	*addr++ = 0x87654321;
-}
-
-static void slab_kernel_map(struct kmem_cache *cachep, void *objp,
-				int map, unsigned long caller)
+static void slab_kernel_map(struct kmem_cache *cachep, void *objp, int map)
 {
 	if (!is_debug_pagealloc_cache(cachep))
 		return;
 
-	if (caller)
-		store_stackinfo(cachep, objp, caller);
-
 	kernel_map_pages(virt_to_page(objp), cachep->size / PAGE_SIZE, map);
 }
 
 #else
 static inline void slab_kernel_map(struct kmem_cache *cachep, void *objp,
-				int map, unsigned long caller) {}
+				int map) {}
 
 #endif
 
@@ -1661,7 +1625,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 
 		if (cachep->flags & SLAB_POISON) {
 			check_poison_obj(cachep, objp);
-			slab_kernel_map(cachep, objp, 1, 0);
+			slab_kernel_map(cachep, objp, 1);
 		}
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone1(cachep, objp) != RED_INACTIVE)
@@ -2433,7 +2397,7 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 		/* need to poison the objs? */
 		if (cachep->flags & SLAB_POISON) {
 			poison_obj(cachep, objp, POISON_FREE);
-			slab_kernel_map(cachep, objp, 0, 0);
+			slab_kernel_map(cachep, objp, 0);
 		}
 	}
 #endif
@@ -2812,7 +2776,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 
 	if (cachep->flags & SLAB_POISON) {
 		poison_obj(cachep, objp, POISON_FREE);
-		slab_kernel_map(cachep, objp, 0, caller);
+		slab_kernel_map(cachep, objp, 0);
 	}
 	return objp;
 }
@@ -3076,7 +3040,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		return objp;
 	if (cachep->flags & SLAB_POISON) {
 		check_poison_obj(cachep, objp);
-		slab_kernel_map(cachep, objp, 1, 0);
+		slab_kernel_map(cachep, objp, 1);
 		poison_obj(cachep, objp, POISON_INUSE);
 	}
 	if (cachep->flags & SLAB_STORE_USER)
-- 
2.20.1 (Apple Git-117)

