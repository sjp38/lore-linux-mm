Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A172C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA2CD2085A
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:43:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LhKqHj9w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA2CD2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F3556B0274; Mon, 20 May 2019 01:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A3C56B0275; Mon, 20 May 2019 01:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B9756B0276; Mon, 20 May 2019 01:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D30D6B0274
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:43:08 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q32so13217442qtk.10
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BWgf9mQL60frF07ii2U3Yx/gnin3umDFroib+xOOshw=;
        b=t4IqVD2JOJWfgEmS6HWhyoJcq6E0ok2NNvR/ndyNSFQKLVgnooHnC4KbSXO6DPBn2s
         7disMB4OziPmjRK0h6ljoHUtwOYlzJodXkOgKacRHYSR2kXUZwj8sxb9FRmGAMUYB70q
         TzrFnnNtoz+MHRhyc9Aw+ITk6t4NjhLgyGQ/FlHEd1AVSeW0irlq/XWl/Tf0x8Ixgcxc
         UyjiTJ0Xr0ecEEXnKTFqaGiojfG4J3JqBlpy4YiTSFOYyTWot8iQum1WibP3QXIxgcoF
         Jq68AvXFkzslFywWeWQ8y4B3ls8IhOaDcVUBpwFJ91xyDTGDd2rA0rVZN0sI9c1Fhvzq
         TfCg==
X-Gm-Message-State: APjAAAUKBdl8Jm00ZNpZcIJhgLVg4jzwAMie3WZGj/XedeEsO4CGOd1+
	vP7A9g1cSyHg4ZYWdOMz/0B/efAyxykSn1wuGL8maCe9ISv0msAzDFfyxSBU/VgYY0evitp2Dfg
	IMoK9sLcZ9G+otd0+4qGfy7vjh8Ag3FeCs94Ts+/eId4iRY03vxMOcYI10YkLEoU=
X-Received: by 2002:a37:b4c6:: with SMTP id d189mr57411648qkf.173.1558330988002;
        Sun, 19 May 2019 22:43:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwis8az85ijfJiecv/3cPCPGNUqV20X2uAqfUskYqXoMeTNK+vV+OTr+blh5Qd4zA0uAtaH
X-Received: by 2002:a37:b4c6:: with SMTP id d189mr57411605qkf.173.1558330987036;
        Sun, 19 May 2019 22:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330987; cv=none;
        d=google.com; s=arc-20160816;
        b=jOs4Nkn2wapHZ3Qxr6+vdOmIKu8XD+VKA17Nbb7pV/zM1PfZwjE5YII8UjRRII6x0h
         x/Tcg0UprCiVNuTGc/kh9OKPP2N/e04bwEPzlGQU+IqhUGevbovqRCWFSCz5ZhdGSxev
         u8RF9xtjeaBLJ3LAz2iN7Bk7HJryde+3PazebRwbMPpFtUzMTh3Vgwnf2ERAqnA6MLBH
         g4B/vODtnBvDzkLjm+m7pFcysGyY5E6HGZFxpM2+twg4HNgh+51ZdoR6XJIVt6ESvjbk
         W4biBw0o2FL3ajWeYXOW9r6f9U/hq30BK+p1s6lKbuRBTtizt1LM4uA5XE2yaMmXaOKK
         RL/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BWgf9mQL60frF07ii2U3Yx/gnin3umDFroib+xOOshw=;
        b=A6IXwPrw9L5q8Y/Bx/zd8Q06TlA+AWQt9DQYa1rXNLcbRVyK0Az6FqSVVC1sxG5dN2
         +7jSlCrWmzhtNpkDFdnWWkH7es9XZzD941kVslhrzDGte75wtdhMTDbfIivTSmHkw0+E
         HCqM4YMs3uQSS3LJedRDoeUmLstoWk1VGQzUJQ3NuePG9o8haK8KkRpkx0nvD4j1xh0j
         v5SGO8m2C+4IgdDVrE8SrCGqJyeoBHuzJuBY/IfniGoR6XV6eCf9e5s6ZTelXlbLZ22r
         JqP0ppamnrFHaEWDp3YHqwIb9y5KrfGMmeW8gV25OF5RKp8XF4dfRiOVrIdGzH8Jwarn
         nm5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=LhKqHj9w;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id u5si2283273qta.21.2019.05.19.22.43.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:43:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=LhKqHj9w;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id BB657115CB;
	Mon, 20 May 2019 01:43:06 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:43:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=BWgf9mQL60frF07ii2U3Yx/gnin3umDFroib+xOOshw=; b=LhKqHj9w
	zvjIxq0G2O5k2GycyyiBsamzi2rk2+Lf+YY+F5xR7uqTFhkUs01LFET99pHIduQs
	zOM4rZdOSvJ/+z966a1bZjVfEqSxqIESB2sj2qYi/MyuhQjzu91wrVGuA9y2tEt/
	krfRq77gRiJ8tckBxpUTJnqfd3NJOGBYPJN2U39hcDUUkSJSWZSjJ0xSt1+Ea1O1
	+jt7qGo8NnY9WOhtrB/Q8GgsmaFNzTIQ9zSeGHSaxKOlKiD0s5oDmFpMAD46hK7W
	JEhgU6aa+NeSITEQ9r1zxvFsz532rqKkHToJnh6sHAdJRobsuaRB9jd+5RQ66NuX
	WpprC/lEu1nFAw==
X-ME-Sender: <xms:aj7iXJT6i9Oat66hbsjAGRKp8ivhzPTtOeQjhFevKqB3toMa-3N_4g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepudeh
X-ME-Proxy: <xmx:aj7iXLsm8RfzRwpzWMqOv4yqNrnHvY2PreCiTcGGNgXUH65_A7ky8A>
    <xmx:aj7iXAxrdVYMTdmWW8Gdd31xDdHcU__M5rtYQ53IYinJWakQoNXpiw>
    <xmx:aj7iXN4O0EDlsxcZeLWMLUQnoXTPf_dzVR16xXlScM2-D2s4qKZjEw>
    <xmx:aj7iXIdowHHWet0oDJd0Uj4YrXknJYhGbESKyg7DQcS8YC1W7Av8MA>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3664D80060;
	Mon, 20 May 2019 01:42:58 -0400 (EDT)
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
Subject: [RFC PATCH v5 16/16] dcache: Add CONFIG_DCACHE_SMO
Date: Mon, 20 May 2019 15:40:17 +1000
Message-Id: <20190520054017.32299-17-tobin@kernel.org>
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

In an attempt to make the SMO patchset as non-invasive as possible add a
config option CONFIG_DCACHE_SMO (under "Memory Management options") for
enabling SMO for the DCACHE.  Whithout this option dcache constructor is
used but no other code is built in, with this option enabled slab
mobility is enabled and the isolate/migrate functions are built in.

Add CONFIG_DCACHE_SMO to guard the partial shrinking of the dcache via
Slab Movable Objects infrastructure.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 4 ++++
 mm/Kconfig  | 7 +++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 0dfe580c2d42..96063e872366 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3072,6 +3072,7 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+#ifdef CONFIG_DCACHE_SMO
 /*
  * d_isolate() - Dentry isolation callback function.
  * @s: The dentry cache.
@@ -3144,6 +3145,7 @@ static void d_partial_shrink(struct kmem_cache *s, void **_unused, int __unused,
 
 	kfree(private);
 }
+#endif	/* CONFIG_DCACHE_SMO */
 
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
@@ -3190,7 +3192,9 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+#ifdef CONFIG_DCACHE_SMO
 	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);
+#endif
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/mm/Kconfig b/mm/Kconfig
index aa8d60e69a01..7dcea76e5ecc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -265,6 +265,13 @@ config SMO_NODE
        help
          On NUMA systems enable moving objects to and from a specified node.
 
+config DCACHE_SMO
+       bool "Enable Slab Movable Objects for the dcache"
+       depends on SLUB
+       help
+         Under memory pressure we can try to free dentry slab cache objects from
+         the partial slab list if this is enabled.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT
 
-- 
2.21.0

