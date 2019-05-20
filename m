Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADB7DC072AF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66A1620863
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="rV/ImNkG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66A1620863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1644F6B000C; Mon, 20 May 2019 01:41:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 116116B000D; Mon, 20 May 2019 01:41:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 003416B000E; Mon, 20 May 2019 01:41:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D47E86B000C
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:41:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q72so2464479qke.19
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:41:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=SYKDcIUq9lsWtxb4kl133qqF3/tTOqLHlnWEhsDaptArWg43FyFUiwVLbPQyIXA7pq
         VILi5IyAwBmepjsEp/on8Du+RQxUxiZAe7eyJaOk4C2lJjW7zQIq9faqnRoD3Epy5a+3
         DMiez7g2iNDEmTlkArPy5vdvdz6QZ7qNfSyKi0uCPE9V0ErQreL3ZnONSuyKdyG6Tc7J
         AKpi9OfOlB/wJfvnrMBjEU4gjTaetpgOT42WVYfihVwbglqkAVtv9B6A4y1ZevNYv/0x
         8+lZuHgvSIO1KQ21efOJ8tNd/OIfyFAeAmLOK9vCPqzJPQsGxPIp8Pu5ieJCLUpco/rc
         /LGA==
X-Gm-Message-State: APjAAAVjFc3U7Nwp/OzptRUY1HdRYcXaLS4QcJaDK11VLvbg4SNK9TsZ
	dTqSX/MFgU2L8MzfwlfXUf2pdeMHsymrBLAkWndVgpXQ9GCm08z6yAf2p714KbmyCvWodzZdawT
	+5vq/vpA1MbUNYBpqka+y9w90D6bCXWsKJHFaa3f5XefDFP3GqT0SCHT8ppmP3QE=
X-Received: by 2002:a0c:d0d4:: with SMTP id b20mr27138609qvh.38.1558330907649;
        Sun, 19 May 2019 22:41:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiJ4uruPJ8GnVlhHIL7BRPidr8NKnDUhVy6jlKgOEE5Ls8pO+5Nr9/Bki2oUGnaQGX1Iab
X-Received: by 2002:a0c:d0d4:: with SMTP id b20mr27138573qvh.38.1558330906799;
        Sun, 19 May 2019 22:41:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330906; cv=none;
        d=google.com; s=arc-20160816;
        b=X/V4l5gr/9KwnbDYKU8GibelOGBQcUSDieAH5El9h/okFaIF5AfWB34W2BFX6o2QPX
         gl5qJRLyKP14my0l5KDd8pAWPXzeYhUcBJhCVF0Vft9ztx30QtHgGaKFbxmjDlAel3VR
         uA+sqJ5zPG0Y9SSVsUqiQF557LaOWqy4jovFvrxFOBZfg1wC3JuQ0H3DG2BGWgX0+2Qc
         vGN4Bmv4l1+oQLRbu2mpHAeH/KM9AfjxwkdGOctYVdrXj4a9aoxoAa2keQCuz9BZROKD
         jDjUZoLDB8X8Hgl3zSEMM1EyJTGv6833VCAftzGhCfn3qYgkN6ziVopPd7UVy49t3rqu
         kSDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=sFRIzjzACrQ1m6FVMpngVbGAsPZp2XmmIA2B7QHBx4MGqJdVg8J9004fdA5TM9LavZ
         DXpoedqEIB+09Nxs/Cf41+gaD5pqEiOYyKH5nOS7Vf97sioN7Dy7yCJoKzp7Svle1PdT
         C/FuHXrM0xvuq4p/y+H2V+7XKz8n3YbtbMXEZrAgHM4MZn9UJ6Mey8GG+fMbzKew6V9r
         8gjAAkist1jZi+QStJygMcqqN9+MW4opJDKhd0KECnOyDWOn/v04sNVpHTeYhljfIFJq
         Ak4RZjolIW0kVyC67IkJ9V7XkFJj8/91NfmBSZIlRUcBm2cV9TKpAA2GZ0JiqC6laFPK
         9kng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="rV/ImNkG";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id s51si1451965qtk.243.2019.05.19.22.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:41:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="rV/ImNkG";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 84B5C4220;
	Mon, 20 May 2019 01:41:46 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:41:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=; b=rV/ImNkG
	ycR32d1zRF48xl4Dc39cUienWu0iKlmdVUToUwm52yebhEK1C11Ucvr7tt0z8qJm
	iAtm3aaFFTJywcEtPiGVKcMGQTjMGvJt/vJ2Ne4ejracT8MrL3WjCjadCF0r6EJN
	OVbo6k05gTSJkCgDCXtHKFKBRXrc8TZUX1ey8kVL4oeZx8GAHUC4hBe5kt6Ry44T
	wu3V/xWcFF2jMiS2AJ/MOwHmI81KsxXnHOyh12Ce+QJ6SCDx9R+7NM1MTD6e88WT
	uI7d2gzOXVe535PQKo5vvdm4fu/7prpiTDuCaEEKWodgyNsRUnQKHsbggHfxA0do
	zI51yaCTbT1iPg==
X-ME-Sender: <xms:Gj7iXP7qBcPaJDO_tVlzfAtrGuXzKQiPkdIijGevuR6Xy6CCEdvmrQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:Gj7iXNtPh7_ndKFdgL6upR2PGIWMotaoLYzqjyrv8tTelHt-yJm32A>
    <xmx:Gj7iXHxzEUSuHYmodLkxUZhidrLlzYpo5yBF8F1n7A-HwWuAGQgHHA>
    <xmx:Gj7iXFaYrkIschBz-zYkxsO682yyzYZmSpwwONPgmuiDvjzwTaSBfg>
    <xmx:Gj7iXN5O0KeG_8AZ-7o0G0Fexm94-QmCiQY8o__wm5A8smUdzSkoww>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6F46A8005B;
	Mon, 20 May 2019 01:41:39 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 05/16] tools/vm/slabinfo: Add remote node defrag ratio output
Date: Mon, 20 May 2019 15:40:06 +1000
Message-Id: <20190520054017.32299-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add output line for NUMA remote node defrag ratio.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index cbfc56c44c2f..d2c22f9ee2d8 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -377,6 +378,10 @@ static void slab_numa(struct slabinfo *s, int mode)
 	if (skip_zero && !s->slabs)
 		return;
 
+	if (mode) {
+		printf("\nNUMA remote node defrag ratio: %3d\n",
+		       s->remote_node_defrag_ratio);
+	}
 	if (!line) {
 		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
@@ -1272,6 +1277,8 @@ static void read_slab_dir(void)
 			slab->cpu_partial_free = get_obj("cpu_partial_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
+			slab->remote_node_defrag_ratio =
+					get_obj("remote_node_defrag_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

