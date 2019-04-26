Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41270C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC6122084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:46:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kCr3+EHQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC6122084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 527966B0005; Fri, 26 Apr 2019 00:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D6D36B0006; Fri, 26 Apr 2019 00:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EDBE6B0007; Fri, 26 Apr 2019 00:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0827C6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:46:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s19so1201421plp.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:46:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=06muS+VdG0qVduapDlZPxR/tXvMQCCq++FI4ubKSySU=;
        b=P/5AivVx5nGa/TZJOCrbBY1q3dmIaKkPG67KZoXPnYF27JXiWZIWwhlCzvZi7iSVov
         kQzWrZCungNo0pq+jiJcvnJTSjZdvxZc1G7SLaW1JWzmAVLHyAa8yYm3fXlx5y0l+qxR
         1KatALbYWtQZ1RgbjeCCuWyin4rQw0NX6+WxVCxEwAh7X6aipT78LYKjCxNYj5y1QEpU
         0KCJRtOrb6bqnwYEkauh4A4+BRpVXbCOlVgjq/22EDshCFoX19XLfTHhm/lPQWkKnqsZ
         eP6u5yz91Rud3VxJ9KKjHzGCuNw//yO71IWDK8foO7V5UHBXxL+pXhk8t9vkptA65nF0
         69Mw==
X-Gm-Message-State: APjAAAXOpE4DNbdASvt1OKse92Cu3CWM786IkFHfb96xiyCfItAl1SPW
	aZLWVAIFi4EjqidfSgr2W9gmhJ7zhsfSh17YuVCYfIdll1y+2f7X+eH0Zcq+PlpkY5GxjMHDEge
	nJjrU6waGx0+O2whLswUzT18wjSxItH4Ki6q0M4QOwFqCeHiD7fRiWHOuCI2RXbrofg==
X-Received: by 2002:a17:902:904a:: with SMTP id w10mr1773349plz.156.1556253978503;
        Thu, 25 Apr 2019 21:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYo2Aa28geNCnf/1XuH1Jp0Dzmys5+tGryaD1tVTwwfZcg/gwh60G0YGJ3D3rhlOZZmfJ0
X-Received: by 2002:a17:902:904a:: with SMTP id w10mr1773301plz.156.1556253977650;
        Thu, 25 Apr 2019 21:46:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556253977; cv=none;
        d=google.com; s=arc-20160816;
        b=NAkKITpqO88ACvq9fx3SgIzWiNGnw/Kg01OOaHgdXt3ITmpmgZlu5KqOXruXBpMVbW
         gXujxuvoT3vBVJ/f75u70PN0FVkcTbz4sY9FfXDe9IIKM13HMl9VnvD7JIXa4WUcwc4H
         6gO7EL+MfN2DfEQtE+kg1XvVduEh8LVSnoiiZ4xXUbbeA75QDZgWeigQ5TYaygYh4GPx
         0XiyTlwty+GL0UhrMFcwV5L0oxsn2O+yC85QHwK63AZ0pjAnvj/1W/v20w8D65uqL48L
         9IzhL8ScTgR1hguzR7kqOvgB/prpmR9QUjBHmQABuYYfyr7TSKjyn9gZz6NCrie57arG
         mTRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=06muS+VdG0qVduapDlZPxR/tXvMQCCq++FI4ubKSySU=;
        b=lLP6brrqR0otCItCAm8CkZ12W/Ofk1B3dO8El5bClnjsoHJ1BKDWy36D/jHP2OOV8G
         suacRoqHWNxBJnp+qjqn5Lu9CPaCr5n17ZnjHJsj0SfUofYwKbhg/xSwz9N3AQE2HJfi
         MmP3B+ZJr2I8TrzUCsmxHOn6aMCG+vBBCkfDDf0yRD1p4aOa4iHsd7l8ohwtZ5IVFgR9
         QKpy1OUOKH6PwEAKqxcvSFI9Z1A1Nn7D7Cm/fzJYDDYi+kRaQaYgGGiYqu5aFUGGpEqf
         hHRFvF2QaoB2KvxRIaAdidmIm/ssGfPqrCOEskbbDrlOooRo95ghefTLIrHAWv2k7cL2
         1Jlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kCr3+EHQ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v2si22498576pgr.41.2019.04.25.21.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:46:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kCr3+EHQ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2547A206A3;
	Fri, 26 Apr 2019 04:46:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556253977;
	bh=bJxctbgGf3dtGdt4mLGuedt/VO75j69L5QbuMWJ/oRc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=kCr3+EHQRSnBmG4q62p7w7C9i1Pi2UmYAxMy1ZGrPULtAoufQff8furAAh76tL3fk
	 xVX/Fvhuzm5i13yAjDx1VD2lb8pWZkceg7mAQ2MK84xUYf5cnmeFstW3q1XInTxBGr
	 BiN5+K0iVIdD8k35g9T4srM+jE1MsVUbi7IKBz7Q=
Date: Thu, 25 Apr 2019 21:46:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, mm-commits@vger.kernel.org,
 yong.wu@mediatek.com, yingjoe.chen@mediatek.com, yehs1@lenovo.com,
 willy@infradead.org, will.deacon@arm.com, vbabka@suse.cz, tfiga@google.com,
 stable@vger.kernel.org, rppt@linux.vnet.ibm.com, robin.murphy@arm.com,
 rientjes@google.com, penberg@kernel.org, mgorman@techsingularity.net,
 matthias.bgg@gmail.com, joro@8bytes.org, iamjoonsoo.kim@lge.com,
 hsinyi@chromium.org, hch@infradead.org, Alexander.Levin@microsoft.com,
 drinkcat@chromium.org, linux-mm@kvack.org
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm
 tree
Message-Id: <20190425214615.b46db647b6a6a82db92e4143@linux-foundation.org>
In-Reply-To: <20190320070516.GD30433@dhcp22.suse.cz>
References: <20190319183751.rWqkf%akpm@linux-foundation.org>
	<20190319191721.GC30433@dhcp22.suse.cz>
	<01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@email.amazonses.com>
	<20190320070516.GD30433@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is presently in limbo.   Should we just drop it?


From: Nicolas Boichat <drinkcat@chromium.org>
Subject: mm: add /sys/kernel/slab/cache/cache_dma32

The patch "mm: add support for kmem caches in DMA32 zone" added support
for SLAB_CACHE_DMA32 kmem caches.  This patch adds the corresponding
/sys/kernel/slab/cache/cache_dma32 entries, and updates the slabinfo tool.

Link: http://lkml.kernel.org/r/20181210011504.122604-4-drinkcat@chromium.org
Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Hsin-Yi Wang <hsinyi@chromium.org>
Cc: Huaisheng Ye <yehs1@lenovo.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Matthias Brugger <matthias.bgg@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Tomasz Figa <tfiga@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Yingjoe Chen <yingjoe.chen@mediatek.com>
Cc: Yong Wu <yong.wu@mediatek.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/ABI/testing/sysfs-kernel-slab |    9 +++++++++
 mm/slub.c                                   |   11 +++++++++++
 tools/vm/slabinfo.c                         |    7 ++++++-
 3 files changed, 26 insertions(+), 1 deletion(-)

--- a/Documentation/ABI/testing/sysfs-kernel-slab~mm-add-sys-kernel-slab-cache-cache_dma32
+++ a/Documentation/ABI/testing/sysfs-kernel-slab
@@ -106,6 +106,15 @@ Description:
 		are from ZONE_DMA.
 		Available when CONFIG_ZONE_DMA is enabled.
 
+What:		/sys/kernel/slab/cache/cache_dma32
+Date:		December 2018
+KernelVersion:	4.21
+Contact:	Nicolas Boichat <drinkcat@chromium.org>
+Description:
+		The cache_dma32 file is read-only and specifies whether objects
+		are from ZONE_DMA32.
+		Available when CONFIG_ZONE_DMA32 is enabled.
+
 What:		/sys/kernel/slab/cache/cpu_slabs
 Date:		May 2007
 KernelVersion:	2.6.22
--- a/mm/slub.c~mm-add-sys-kernel-slab-cache-cache_dma32
+++ a/mm/slub.c
@@ -5112,6 +5112,14 @@ static ssize_t cache_dma_show(struct kme
 SLAB_ATTR_RO(cache_dma);
 #endif
 
+#ifdef CONFIG_ZONE_DMA32
+static ssize_t cache_dma32_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_CACHE_DMA32));
+}
+SLAB_ATTR_RO(cache_dma32);
+#endif
+
 static ssize_t usersize_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%u\n", s->usersize);
@@ -5452,6 +5460,9 @@ static struct attribute *slab_attrs[] =
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
+#ifdef CONFIG_ZONE_DMA32
+	&cache_dma32_attr.attr,
+#endif
 #ifdef CONFIG_NUMA
 	&remote_node_defrag_ratio_attr.attr,
 #endif
--- a/tools/vm/slabinfo.c~mm-add-sys-kernel-slab-cache-cache_dma32
+++ a/tools/vm/slabinfo.c
@@ -29,7 +29,7 @@ struct slabinfo {
 	char *name;
 	int alias;
 	int refs;
-	int aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
+	int aliases, align, cache_dma, cache_dma32, cpu_slabs, destroy_by_rcu;
 	unsigned int hwcache_align, object_size, objs_per_slab;
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
@@ -534,6 +534,8 @@ static void report(struct slabinfo *s)
 		printf("** Hardware cacheline aligned\n");
 	if (s->cache_dma)
 		printf("** Memory is allocated in a special DMA zone\n");
+	if (s->cache_dma32)
+		printf("** Memory is allocated in a special DMA32 zone\n");
 	if (s->destroy_by_rcu)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
@@ -602,6 +604,8 @@ static void slabcache(struct slabinfo *s
 		*p++ = '*';
 	if (s->cache_dma)
 		*p++ = 'd';
+	if (s->cache_dma32)
+		*p++ = 'D';
 	if (s->hwcache_align)
 		*p++ = 'A';
 	if (s->poison)
@@ -1208,6 +1212,7 @@ static void read_slab_dir(void)
 			slab->aliases = get_obj("aliases");
 			slab->align = get_obj("align");
 			slab->cache_dma = get_obj("cache_dma");
+			slab->cache_dma32 = get_obj("cache_dma32");
 			slab->cpu_slabs = get_obj("cpu_slabs");
 			slab->destroy_by_rcu = get_obj("destroy_by_rcu");
 			slab->hwcache_align = get_obj("hwcache_align");
_

