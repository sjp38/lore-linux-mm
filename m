Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A1ADC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 043FB206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZcsCbH2n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 043FB206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EF386B026C; Mon, 20 May 2019 01:42:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A0426B026D; Mon, 20 May 2019 01:42:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 840D36B026E; Mon, 20 May 2019 01:42:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 648F56B026C
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:42:39 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id y13so13223217qtc.7
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:42:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9XDuSxwKrHTa5OuRmvXZIbQcLUkhgPbDvSR6tXiHu4g=;
        b=l8ayigKylHO8o5S3u0WCHrxk8lMiHKmRh8ZvlRVcRTksiyxfDliECUKdO/ZFyegYnI
         85hGsUhL7dBdhJ7yRV/j1NVPPBROC1t+EUHVpH76CjTYEW9vubaCXzrPqFfmAzTom1pM
         aTdgPCH/qqnZ6vNWL/ge/NjnmvNxY9vbnqB+Wr4tvv89LqjUSGO0eznYlDxcMZeXh4vS
         2vbpplvWzfU16h0fmA2LAF0wyyAqEQYgWYu2g8r6QQw7bjijVM+WWjKLnT/1G08fvKNL
         ASAxjCPc/ie3eBBmSJbAQIcmnvc9XiWoMny+qk2t9cWBCTbNRDsPtBULlUNAt3q0Unx6
         G41g==
X-Gm-Message-State: APjAAAXFkzOnkLq1sHSwJzQrIDQWS3jzcJpav45KRXTXh/Iva2QPNAfK
	MC5cLPdvtckdRWPUpHGJGG+rGQz18hajsaZfRQqCb6+QXnMhE3A+eDAmtTfaquQJiPHcLAG7a2H
	9PGyEN8G6iiaObPCtahYEooudrcIpWBngyXMe85NWo6w5PZrKVF/Oub5SHbLz+4Q=
X-Received: by 2002:a37:dcc1:: with SMTP id v184mr47418741qki.338.1558330959121;
        Sun, 19 May 2019 22:42:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA0M5Ks5QAEgArrzqYon8ercJEbpE2xYbRc4HBrjR1sc68TGHogphI9VBdF1s/loUqmSKs
X-Received: by 2002:a37:dcc1:: with SMTP id v184mr47418681qki.338.1558330957768;
        Sun, 19 May 2019 22:42:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330957; cv=none;
        d=google.com; s=arc-20160816;
        b=nKjC+WgGTutG0Bc1NVmbYGAaWLrOnM0j60diM62xbcX+s/4xNJXuDZadbuMqd2laCB
         DqrzAEyM0wf8yKRDEdRtH12IigoAiwjyB94e13FLtF/vVkj/g8Gfmk7CWvTS3RfryyXX
         AveUi+iEkvVjgIMdneOH3DC3CN3qFBFOMDUf3NVCaTlSDE2yJW3PsnyK06aUSUe4h4da
         UDA19mX2gNxxOOP2qUzOMU6/0Gnhp+BOY/JyL5Hu0KllmZHJW/o6/3Ok4RnwE95iUDff
         JZggKLt41iaJ5SY2mF20OnbkoJFUd/wmSYZP3zJQRqrqphZjZXqVkdKWavRfhz2NTFP1
         Qk5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9XDuSxwKrHTa5OuRmvXZIbQcLUkhgPbDvSR6tXiHu4g=;
        b=R0BEXY39MG60/pZIMKt1A/WT7gxKnExy2zQbCubf1OTwr8ySofHvLmFlS7qw+w6i+c
         D+4VOqPbLLRQgn9x/DRoEJSjNOJM0mTPraZ7GI/HqVQONmJUs4HnzTvtgZvSMtclINVn
         XePWXQ+X1yalVz7GFtho9675879BpbduMMihiy39JizL+9T7Q6dXYQmdZ4TmH6qU866+
         Yz91y9e4WKtT2c4mgsx7xvsrHRDHl0W6oYNFFzfzwuSJkATS+yCSDkWNYLFS7dQqr5zq
         IfjP7Ge0Q9DPTuCzJPzEmw15GtCM5Zs7UGh9FjE72qT/+mrtzWz7rUdhPNguudApSOR/
         JpEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ZcsCbH2n;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id v63si1558026qkc.268.2019.05.19.22.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ZcsCbH2n;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 7AE6FDC02;
	Mon, 20 May 2019 01:42:37 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=9XDuSxwKrHTa5OuRmvXZIbQcLUkhgPbDvSR6tXiHu4g=; b=ZcsCbH2n
	kx1kNHGoZK7ikUL9wnmYUEIsxrCWj1knqAFlyLdJaK9uiLS4iwz5G6z8XnewR98P
	De3WXWOu9CSDdOa9H4CPAzqGZhflIdG8VTY1+mkbcNeVpIoMLEqoaiCKuEDKQOHq
	HitUxfue0bnJaGOnMPDRx7f5SXaX4p/RBYpc1kJKQNcn9BqhxRNp5wyMNC1K8Fp8
	M4o6TSgZ+aaec/tmYMbuJ2fdiNGwLkapRM7eW3288aSZR+rc2lr0UlsRxsHRWE4u
	G+tcdDg2vlwDKOCGt2/jhDtYvydr8vwlB8kSArZcUjXvmFFU4spRPENzaXHDQsAT
	nq5LQTuebmFuXA==
X-ME-Sender: <xms:TT7iXP7sdPmzL_XjBf-SCXt2lnZFK6UEFfWrE0MdSG8ZVHKJwf6JdA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepuddu
X-ME-Proxy: <xmx:TT7iXM3S0wWSHuOZ_QMDFp8AKLmAVo8ovx_PaEtDM4bRF-J-XGjHvw>
    <xmx:TT7iXNr4NvtjYgQKd4zatTiyeRAm_GdEzGo_suVqMn_-nLOIRSbLUg>
    <xmx:TT7iXGku1-N4F3BSm6qgpO5GVx4p-PIPIRlDT3JcI0ppwPMMxzcv8A>
    <xmx:TT7iXLnTVkFyQncKoIgfxX4T90UGnscdbg6U_lbRfV3mB1KvlOi-RA>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5638E8005B;
	Mon, 20 May 2019 01:42:30 -0400 (EDT)
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
Subject: [RFC PATCH v5 12/16] slub: Enable moving objects to/from specific nodes
Date: Mon, 20 May 2019 15:40:13 +1000
Message-Id: <20190520054017.32299-13-tobin@kernel.org>
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

We have just implemented Slab Movable Objects (object migration).
Currently object migration is used to defrag a cache.  On NUMA systems
it would be nice to be able to control the source and destination nodes
when moving objects.

Add CONFIG_SMO_NODE to guard this feature.  CONFIG_SMO_NODE depends on
CONFIG_SLUB_DEBUG because we use the full list.

Implement moving all objects (including those in full slabs) to a
specific node.  Expose this functionality to userspace via a sysfs entry.

Add sysfs entry:

   /sysfs/kernel/slab/<cache>/move

With this users get access to the following functionality:

 - Move all objects to specified node.

   	echo "N1" > move

 - Move all objects from specified node to other specified
   node (from N1 -> to N2):

   	echo "N1 N2" > move

This also enables shrinking slabs on a specific node:

   	echo "N1 N1" > move

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/Kconfig |   7 ++
 mm/slub.c  | 249 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 256 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index ee8d1f311858..aa8d60e69a01 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -258,6 +258,13 @@ config ARCH_ENABLE_THP_MIGRATION
 config CONTIG_ALLOC
        def_bool (MEMORY_ISOLATION && COMPACTION) || CMA
 
+config SMO_NODE
+       bool "Enable per node control of Slab Movable Objects"
+       depends on SLUB && SYSFS
+       select SLUB_DEBUG
+       help
+         On NUMA systems enable moving objects to and from a specified node.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT
 
diff --git a/mm/slub.c b/mm/slub.c
index 2157205df7ba..9582f2fc97d2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4336,6 +4336,106 @@ static void move_slab_page(struct page *page, void *scratch, int node)
 	s->migrate(s, vector, count, node, private);
 }
 
+#ifdef CONFIG_SMO_NODE
+/*
+ * kmem_cache_move() - Attempt to move all slab objects.
+ * @s: The cache we are working on.
+ * @node: The node to move objects away from.
+ * @target_node: The node to move objects on to.
+ *
+ * Attempts to move all objects (partial slabs and full slabs) to target
+ * node.
+ *
+ * Context: Takes the list_lock.
+ * Return: The number of slabs remaining on node.
+ */
+static unsigned long kmem_cache_move(struct kmem_cache *s,
+				     int node, int target_node)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+	LIST_HEAD(move_list);
+	struct page *page, *page2;
+	unsigned long flags;
+	void **scratch;
+
+	if (!s->migrate) {
+		pr_warn("%s SMO not enabled, cannot move objects\n", s->name);
+		goto out;
+	}
+
+	scratch = alloc_scratch(s);
+	if (!scratch)
+		goto out;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+
+	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+		if (!slab_trylock(page))
+			/* Busy slab. Get out of the way */
+			continue;
+
+		if (page->inuse) {
+			list_move(&page->lru, &move_list);
+			/* Stop page being considered for allocations */
+			n->nr_partial--;
+			page->frozen = 1;
+
+			slab_unlock(page);
+		} else {	/* Empty slab page */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+	list_for_each_entry_safe(page, page2, &n->full, lru) {
+		if (!slab_trylock(page))
+			continue;
+
+		list_move(&page->lru, &move_list);
+		page->frozen = 1;
+		slab_unlock(page);
+	}
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	list_for_each_entry(page, &move_list, lru) {
+		if (page->inuse)
+			move_slab_page(page, scratch, target_node);
+	}
+	kfree(scratch);
+
+	/* Bail here to save taking the list_lock */
+	if (list_empty(&move_list))
+		goto out;
+
+	/* Inspect results and dispose of pages */
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &move_list, lru) {
+		list_del(&page->lru);
+		slab_lock(page);
+		page->frozen = 0;
+
+		if (page->inuse) {
+			if (page->inuse == page->objects) {
+				list_add(&page->lru, &n->full);
+				slab_unlock(page);
+			} else {
+				n->nr_partial++;
+				list_add_tail(&page->lru, &n->partial);
+				slab_unlock(page);
+			}
+		} else {
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+out:
+	return atomic_long_read(&n->nr_slabs);
+}
+#endif	/* CONFIG_SMO_NODE */
+
 /*
  * kmem_cache_defrag() - Defragment node.
  * @s: cache we are working on.
@@ -4450,6 +4550,32 @@ static unsigned long kmem_cache_defrag(struct kmem_cache *s,
 	return n->nr_partial;
 }
 
+#ifdef CONFIG_SMO_NODE
+/*
+ * kmem_cache_move_to_node() - Move all slab objects to node.
+ * @s: The cache we are working on.
+ * @node: The target node to move objects to.
+ *
+ * Attempt to move all slab objects from all nodes to @node.
+ *
+ * Return: The total number of slabs left on emptied nodes.
+ */
+static unsigned long kmem_cache_move_to_node(struct kmem_cache *s, int node)
+{
+	unsigned long left = 0;
+	int nid;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		if (nid == node)
+			continue;
+
+		left += kmem_cache_move(s, nid, node);
+	}
+
+	return left;
+}
+#endif
+
 /**
  * kmem_defrag_slabs() - Defrag slab caches.
  * @node: The node to defrag or -1 for all nodes.
@@ -5594,6 +5720,126 @@ static ssize_t shrink_store(struct kmem_cache *s,
 }
 SLAB_ATTR(shrink);
 
+#ifdef CONFIG_SMO_NODE
+static ssize_t move_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+/*
+ * parse_move_store_input() - Parse buf getting integer arguments.
+ * @buf: Buffer to parse.
+ * @length: Length of @buf.
+ * @arg0: Return parameter, first argument.
+ * @arg1: Return parameter, second argument.
+ *
+ * Parses the input from user write to sysfs file 'move'.  Input string
+ * should contain either one or two node specifiers of form Nx where x
+ * is an integer specifying the NUMA node ID.  'N' or 'n' may be used.
+ * n/N may be omitted.
+ *
+ * e.g.
+ *     echo 'N1' > /sysfs/kernel/slab/cache/move
+ * or
+ *     echo 'N0 N2' > /sysfs/kernel/slab/cache/move
+ *
+ * Regex matching accepted forms: '[nN]?[0-9]( [nN]?[0-9])?'
+ *
+ * FIXME: This is really fragile.  Input must be exactly correct,
+ *        spurious whitespace causes parse errors.
+ *
+ * Return: 0 if an argument was successfully converted, or an error code.
+ */
+static ssize_t parse_move_store_input(const char *buf, size_t length,
+				      long *arg0, long *arg1)
+{
+	char *s, *save, *ptr;
+	int ret = 0;
+
+	if (!buf)
+		return -EINVAL;
+
+	s = kstrdup(buf, GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+	save = s;
+
+	if (s[length - 1] == '\n') {
+		s[length - 1] = '\0';
+		length--;
+	}
+
+	ptr = strsep(&s, " ");
+	if (!ptr || strcmp(ptr, "") == 0) {
+		ret = 0;
+		goto out;
+	}
+
+	if (*ptr == 'N' || *ptr == 'n')
+		ptr++;
+	ret = kstrtol(ptr, 10, arg0);
+	if (ret < 0)
+		goto out;
+
+	if (s) {
+		if (*s == 'N' || *s == 'n')
+			s++;
+		ret = kstrtol(s, 10, arg1);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = 0;
+out:
+	kfree(save);
+	return ret;
+}
+
+static bool is_valid_node(int node)
+{
+	int nid;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		if (nid == node)
+			return true;
+	}
+	return false;
+}
+
+/*
+ * move_store() - Move objects between nodes.
+ * @s: The cache we are working on.
+ * @buf: String received.
+ * @length: Length of @buf.
+ *
+ * Writes to /sys/kernel/slab/<cache>/move are interpreted as follows:
+ *
+ *  echo "N1" > move       : Move all objects (from all nodes) to node 1.
+ *  echo "N0 N1" > move    : Move all objects from node 0 to node 1.
+ *
+ * 'N' may be omitted:
+ */
+static ssize_t move_store(struct kmem_cache *s, const char *buf, size_t length)
+{
+	long arg0 = -1;
+	long arg1 = -1;
+	int ret;
+
+	ret = parse_move_store_input(buf, length, &arg0, &arg1);
+	if (ret < 0)
+		return -EINVAL;
+
+	if (is_valid_node(arg0) && is_valid_node(arg1))
+		(void)kmem_cache_move(s, arg0, arg1);
+	else if (is_valid_node(arg0))
+		(void)kmem_cache_move_to_node(s, arg0);
+
+	/* FIXME: What should we be returning here? */
+	return length;
+}
+SLAB_ATTR(move);
+#endif	/* CONFIG_SMO_NODE */
+
 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -5718,6 +5964,9 @@ static struct attribute *slab_attrs[] = {
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
+#ifdef CONFIG_SMO_NODE
+	&move_attr.attr,
+#endif
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
-- 
2.21.0

