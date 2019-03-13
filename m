Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5ABDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73F9A20693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GN9yesFe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73F9A20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BE6C8E0004; Wed, 13 Mar 2019 01:21:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1700E8E0002; Wed, 13 Mar 2019 01:21:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F29488E0004; Wed, 13 Mar 2019 01:21:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD4928E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:21:11 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y6so575419qke.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 22:21:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=acU2gA0XupWBWu0QZQ+K9+WO5Dqp8Z/Fo1Pi8Ye78KI=;
        b=LNa1DrpqL4EvfyvCfctVbLOiN1a+QlLT3R4+/Niayqlj1RiqfSfTSffB8pQIVmGNXI
         sAL1X7t1eQzIfZ46uc0lF7ptB49O4r2kSnAi+3jrJ2fuHAcpDSwxNCRS0GqlI7deyLG1
         PZjINpbfE5s4j7Y6pNoaA3O40SShfAib9zwaixCTJQVFUmwHPuhxaSo8mFXd5gWCWv0I
         BSDB2PkGbdns4VWi/lK12XBRb0g8EB7TsrUtyvfmoDLPD7j/dCTgp11FU6wgARWJz5Zb
         M3gfSlk2UwarHSxC48RBsmP4fHyr1hS0JRBsy8gbdh9rB4Eax+FVs0PTYRrLy72z3QKV
         zMog==
X-Gm-Message-State: APjAAAWowY6uZT3rYhjfIFLRy683BQm2GCXyG7zKhYLCZYwIUNOfYSnf
	wMLeTvX4nDrBiIHoiwh1g0cpZK+d08By09c2JiHM9XW+g2QMaEa8py+W1au8m3WFPULWAtwIYS9
	LY1KLPF9E/fIJEr+jFscDtkzPJEjDeHlFMjai4j+35nYwCE9qyeEW3X0zj8AGe0M=
X-Received: by 2002:a0c:e989:: with SMTP id z9mr9157934qvn.192.1552454471626;
        Tue, 12 Mar 2019 22:21:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+a6h0Zq+XlKqerwKFkEkjvfQTQAYBcqIqJoKspijxrM1D6x65THQeXY2YivcJz74sg3QE
X-Received: by 2002:a0c:e989:: with SMTP id z9mr9157885qvn.192.1552454470327;
        Tue, 12 Mar 2019 22:21:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552454470; cv=none;
        d=google.com; s=arc-20160816;
        b=YOCykvtgBXQ7tsQs/Sepq2M0hJQv7jeU3Nwj82W78NrC/U0fSFS4AXWfvuuYOKknaA
         xAhZdROWe5Zabu9b50gkhQMGcCYrU1WW7TeZ9sfvGfcN6objKzferfiMWE+tbBo7uJtF
         nzTYt7e18ecSZpuFGz3zhlmqk/DIgTkzv8UUKKtE+PHS1mcfTje2ULkv+NcusV+bBigH
         lZkTH3cMSc/0qsPFEzdFKkm1lVOXlTiNEGdwpV9KhhINudOO+pfew//X9MrKXW90Ah6S
         M5uwFGO4fkfofnztSHLVS6n1m0y99IzrN65WVoPHrHr5XdnqapL4QQdfjyx+ysOKZvv4
         qA3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=acU2gA0XupWBWu0QZQ+K9+WO5Dqp8Z/Fo1Pi8Ye78KI=;
        b=NMYlpx9Y5ewRJ2SH33rIT4/1Je+qRZUMb79UMqbxk6/9BWT+5GvhBcLbmpFZha91um
         hpOg1PNyEaTpE7G39RS9A8B2Y6lh6HlqniOTZTJzpPcF1KdN2NLIwLh6KmE9D/SrhqYa
         u25tiXW8/nZDfvTeqjd5NWkDNtnxA6tAXj/iGUchEoy8Jptmq5wvUWJMx7UNA0ZvNPKp
         PtK1iGyagEtkeJ158nsLsTykAACPo3v/F+b9LbJlMTnjNHw8T96RceU8gHZrgFxB+gOE
         WcAbiayDS8sCLDDZSZ12BQeDv/4zW27b7Ee1wJ5Mz5wdXHFjVt6cVy9389/gojJdsP9P
         QH3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=GN9yesFe;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id c24si187293qkj.36.2019.03.12.22.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 22:21:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=GN9yesFe;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id A62DC38B1;
	Wed, 13 Mar 2019 01:21:08 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 13 Mar 2019 01:21:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=acU2gA0XupWBWu0QZQ+K9+WO5Dqp8Z/Fo1Pi8Ye78KI=; b=GN9yesFe
	fo3KT4XAJDo714mB4gMydBPdMeMcnDRvhbZd+Ds8bNI2CGiKHRAoXJ7qpAFIl0wt
	wQhyVSgBu3pX1OUcdyYEhiWu0izqCbGg6ir2mVHVycMsrHFVyBU8C164PbRHmtxg
	AVCaisFmX5hUQQK+n+uQJ6scViCswM4tfjP3sZFO1m3fWxYLrpN+LeQLoLYK/Q9I
	Jttj8HFw54NR6+Ry+RcSxZ+Yl5+a332qgVj5cqPU+VFhrSgZkXx4+2hpFbfEXcYq
	DNlh0hsT2LzY5y7oL6AA8XuMejIP21MXq6X8GllKS4On7arir1leNxSISDUcF0a9
	m4nvuUJJivoAaw==
X-ME-Sender: <xms:RJOIXIBU9nK3Ls10XqXA4rlZXhrZx29XOc2fk61Dlh2u1YUg82EhNQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeelgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:RJOIXB5x1Tb5a0ffmp8qJjF6CBLG_1KdLyvguUM2bX7D_oG9WLXbmA>
    <xmx:RJOIXBIi-GYj0em8GTHA9M-yTfSs6BuyBtVwQC2wkMjuXaVcTzQwQg>
    <xmx:RJOIXKuJHrY0vRNeYrBXHnumkuiCcH0hyouNcI5UtdwWAwiFrmh7bA>
    <xmx:RJOIXNWHQwT-VN01S5SRcrcV0B5RJGITcOSJFDtedSCRH7iK4SHpSw>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id CB509E4693;
	Wed, 13 Mar 2019 01:21:04 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/5] slub: Add comments to endif pre-processor macros
Date: Wed, 13 Mar 2019 16:20:26 +1100
Message-Id: <20190313052030.13392-2-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190313052030.13392-1-tobin@kernel.org>
References: <20190313052030.13392-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SLUB allocator makes heavy use of ifdef/endif pre-processor macros.
The pairing of these statements is at times hard to follow e.g. if the
pair are further than a screen apart or if there are nested pairs.  We
can reduce cognitive load by adding a comment to the endif statement of
form

       #ifdef CONFIG_FOO
       ...
       #endif /* CONFIG_FOO */

Add comments to endif pre-processor macros if ifdef/endif pair is not
immediately apparent.

Reviewed-by: Roman Gushchin <guro@fb.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1b08fbcb7e61..b282e22885cd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1951,7 +1951,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 			}
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
-#endif
+#endif	/* CONFIG_NUMA */
 	return NULL;
 }
 
@@ -2249,7 +2249,7 @@ static void unfreeze_partials(struct kmem_cache *s,
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
 	}
-#endif
+#endif	/* CONFIG_SLUB_CPU_PARTIAL */
 }
 
 /*
@@ -2308,7 +2308,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		local_irq_restore(flags);
 	}
 	preempt_enable();
-#endif
+#endif	/* CONFIG_SLUB_CPU_PARTIAL */
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
@@ -2813,7 +2813,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
-#endif
+#endif	/* CONFIG_NUMA */
 
 /*
  * Slow path handling. This may still be called frequently since objects
@@ -3845,7 +3845,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
-#endif
+#endif	/* CONFIG_NUMA */
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
@@ -4063,7 +4063,7 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
-#endif
+#endif	/* CONFIG_MEMCG */
 
 static int slab_mem_going_offline_callback(void *arg)
 {
@@ -4696,7 +4696,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 		len += sprintf(buf, "No data\n");
 	return len;
 }
-#endif
+#endif	/* CONFIG_SLUB_DEBUG */
 
 #ifdef SLUB_RESILIENCY_TEST
 static void __init resiliency_test(void)
@@ -4756,7 +4756,7 @@ static void __init resiliency_test(void)
 #ifdef CONFIG_SYSFS
 static void resiliency_test(void) {};
 #endif
-#endif
+#endif	/* SLUB_RESILIENCY_TEST */
 
 #ifdef CONFIG_SYSFS
 enum slab_stat_type {
@@ -5413,7 +5413,7 @@ STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
 STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
 STAT_ATTR(CPU_PARTIAL_NODE, cpu_partial_node);
 STAT_ATTR(CPU_PARTIAL_DRAIN, cpu_partial_drain);
-#endif
+#endif	/* CONFIG_SLUB_STATS */
 
 static struct attribute *slab_attrs[] = {
 	&slab_size_attr.attr,
@@ -5614,7 +5614,7 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 
 	if (buffer)
 		free_page((unsigned long)buffer);
-#endif
+#endif	/* CONFIG_MEMCG */
 }
 
 static void kmem_cache_release(struct kobject *k)
-- 
2.21.0

