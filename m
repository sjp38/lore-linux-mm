Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6224CC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C13E206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OH5SuBaX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C13E206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8B6A6B026E; Mon, 20 May 2019 01:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3D516B026F; Mon, 20 May 2019 01:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92BC86B0270; Mon, 20 May 2019 01:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71BFD6B026E
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:42:46 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id h4so13270977qtq.3
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+MHoJQqVfWBEgl6V34UkKqnW9RMSUkovsQXORa/Ihwg=;
        b=aUsm0564aiwA2hFdMZPGpDOeiMalp15Ir9Qq/BqoPbuOpki4oTQl9rlQ12rQ5tp1cK
         yvc8OOy1raBVVwWwH95ABOMGC2guYR8ffjQezR9CB3krsoRW0Tuks2f3+kBRoFKkYTFy
         +BSat0bbhBZWOyCP6W2wnhlP8wRlep8NKUwYVVekhCe8iPfEALcCKlyGcxtJn0HWm0rW
         ZLz7D717gyHQvMf5Z0Y+qq0iupchmFVA7ELJY5c23aW603dlJniHHhvH0dzKmlHqpMp4
         31zfdc5XlCgoWALBq8vEJ3hbuxqXGeqwTPbXTUGbKnsNXKxHtO5WYNA+iJmb/lKIVqUg
         NQSA==
X-Gm-Message-State: APjAAAU9nP8hkJ9miyJM0V/n7nvmgjlewNGewCqPnSjSWI88GgSxTFH3
	oyTlMxhqo7wHOidBnWI1KSrlhVvpRn0T6O6v5IHANei5wc3nJLcCONyVKco0ZF7bVMKJKHdqW7l
	mVxriQsXQeU9XVZqMAMVn0AKkhjOiqgyhY6OksF5O9eds9MASjlfr6/bA5UnbE0Q=
X-Received: by 2002:ac8:5218:: with SMTP id r24mr21864398qtn.177.1558330966191;
        Sun, 19 May 2019 22:42:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzB980/laFvBlyri34W1W/IuNJBUJB5JJ2+err6cmtn1XEMdVBzFUX7aidP9/BfpwT5QxRu
X-Received: by 2002:ac8:5218:: with SMTP id r24mr21864344qtn.177.1558330964919;
        Sun, 19 May 2019 22:42:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330964; cv=none;
        d=google.com; s=arc-20160816;
        b=lyLSrM2CwxcQp9mYmDSYPz7L8c/0YulHehKDVVkCez0T092Vt4NH89xcrr923ZrTZX
         uLEx9D7mZ+4uD0SeAMUaTyiAuSRcquQBSL6k8+ssrM+tk3dFH6HPwmJlORzyz70cmNOn
         desLIEk8/1jMIfejqgSwXpA9OsRUO7pv7z2z4kfNIC4vyxsc3dcHTCWVT4vaQgLK+y/V
         2G0o27W4TtSvIRdCm6lsmxc1TnD3yHBZUgE1/VDjX9A1T2BzMHawcLY2XwbNDlmekWkc
         VtLZCNXVha9Wb8IAJagGYDxCdTfJdTOx/JF1dzJamxO123YR0g4y0LHYVkhCVkBxhN75
         DAIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+MHoJQqVfWBEgl6V34UkKqnW9RMSUkovsQXORa/Ihwg=;
        b=YbhLfZxOvujy3s/PhUVhk7v/wEZAsgAB0kcpvyfaWL4IBwkPpmCEHeUwEx56VK0Zkw
         S/O3Prih4G48V2OjlKfjMAxi8ItHS0Q2G70P/j2kAwWbAGw162rM7yW8j89rvm1/c4jv
         LNZR9H/TQKPzXAirjQxn8m8tALLoReFvCB5W4dEe/3QKavJY92q2dwRNBAVkeNc/8DVL
         vzCKz6GIxZ6G4+myLVuYgbUlBdGPEaE+Ud3NkmeaBrK34khhqyweWWt66kv0k4bBxJZF
         pdsgdUukQcvcaFJOb17C5opLEQaSljOHsP4JLSMpfEZ2DqisLsinKaXNmcnufyoceRRB
         kEpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=OH5SuBaX;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id p50si8818707qta.152.2019.05.19.22.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=OH5SuBaX;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 9DD9EF70A;
	Mon, 20 May 2019 01:42:44 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=+MHoJQqVfWBEgl6V34UkKqnW9RMSUkovsQXORa/Ihwg=; b=OH5SuBaX
	TPeWZdZ2LHrhURIZxeT4YNv8Mb3OH2xu451Ritc63buiCSMtLPLAf/flQMTXsodV
	fG/fYkdm4HiKKbE7cPuLKT5GhX6cyeOBw2TqFFch7AFEG1ADwFJMziSL3ot/LXRP
	lzEbzPCrgy4o6u8wNcFpuZDydWVAoKgc1EtgHcO6yds7N+6QhhAtj4KjfWdqSlIs
	hjpxa7KenHDmVQRfPXGPZfJJF2Qf26SO3vu1Vd2YopV6OKI+BSQKlpZ5xwmYwZn2
	m3Z3EVTZJyoIWr/c9b5rU4ulpRbzoTf/UiHSbmJOwWVrsRTQf4uXlbZzFl2RsbtT
	Pde5ZnF1T9o4Jw==
X-ME-Sender: <xms:VD7iXOdDUUTuHd4pMbYYE5RNK4j1GVMfs4G9tAOY7_W1coXts_EHuw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepuddv
X-ME-Proxy: <xmx:VD7iXNYBzixNpRFN3TS6i3OCVHmPrAI8Rw_t6xyIyTRT9FW3ukG5Uw>
    <xmx:VD7iXAYKXU8wLC5sIV5ED4oxSaO1wnCojvHrzIRTnUpCePtlhn8iiQ>
    <xmx:VD7iXCL56VWMBLs7Cjiohfu0sAf9CrtPs7hUOQMFHBVY_y2jsIiTVQ>
    <xmx:VD7iXNJpn2jcOmYMIUx50Zl4HP5xdX4Xndmzno2fTAVwHgz1caq_Ng>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8BB218005B;
	Mon, 20 May 2019 01:42:37 -0400 (EDT)
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
Subject: [RFC PATCH v5 13/16] slub: Enable balancing slabs across nodes
Date: Mon, 20 May 2019 15:40:14 +1000
Message-Id: <20190520054017.32299-14-tobin@kernel.org>
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

We have just implemented Slab Movable Objects (SMO).  On NUMA systems
slabs can become unbalanced i.e. many slabs on one node while other
nodes have few slabs.  Using SMO we can balance the slabs across all
the nodes.

The algorithm used is as follows:

 1. Move all objects to node 0 (this has the effect of defragmenting the
    cache).

 2. Calculate the desired number of slabs for each node (this is done
    using the approximation nr_slabs / nr_nodes).

 3. Loop over the nodes moving the desired number of slabs from node 0
    to the node.

Feature is conditionally built in with CONFIG_SMO_NODE, this is because
we need the full list (we enable SLUB_DEBUG to get this).  Future
version may separate final list out of SLUB_DEBUG.

Expose this functionality to userspace via a sysfs entry.  Add sysfs
entry:

       /sysfs/kernel/slab/<cache>/balance

Write of '1' to this file triggers balance, no other value accepted.

This feature relies on SMO being enable for the cache, this is done with
a call to, after the isolate/migrate functions have been defined.

	kmem_cache_setup_mobility(s, isolate, migrate)

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 120 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 9582f2fc97d2..25b6d1e408e3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4574,6 +4574,109 @@ static unsigned long kmem_cache_move_to_node(struct kmem_cache *s, int node)
 
 	return left;
 }
+
+/*
+ * kmem_cache_move_slabs() - Attempt to move @num slabs to target_node,
+ * @s: The cache we are working on.
+ * @node: The node to move objects from.
+ * @target_node: The node to move objects to.
+ * @num: The number of slabs to move.
+ *
+ * Attempts to move @num slabs from @node to @target_node.  This is done
+ * by migrating objects from slabs on the full_list.
+ *
+ * Return: The number of slabs moved or error code.
+ */
+static long kmem_cache_move_slabs(struct kmem_cache *s,
+				  int node, int target_node, long num)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+	LIST_HEAD(move_list);
+	struct page *page, *page2;
+	unsigned long flags;
+	void **scratch;
+	long done = 0;
+
+	if (node == target_node)
+		return -EINVAL;
+
+	scratch = alloc_scratch(s);
+	if (!scratch)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &n->full, lru) {
+		if (!slab_trylock(page))
+			/* Busy slab. Get out of the way */
+			continue;
+
+		list_move(&page->lru, &move_list);
+		page->frozen = 1;
+		slab_unlock(page);
+
+		if (++done >= num)
+			break;
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	list_for_each_entry(page, &move_list, lru) {
+		if (page->inuse)
+			move_slab_page(page, scratch, target_node);
+	}
+	kfree(scratch);
+
+	/* Inspect results and dispose of pages */
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &move_list, lru) {
+		list_del(&page->lru);
+		slab_lock(page);
+		page->frozen = 0;
+
+		if (page->inuse) {
+			/*
+			 * This is best effort only, if slab still has
+			 * objects just put it back on the partial list.
+			 */
+			n->nr_partial++;
+			list_add_tail(&page->lru, &n->partial);
+			slab_unlock(page);
+		} else {
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	return done;
+}
+
+/*
+ * kmem_cache_balance_nodes() - Balance slabs across nodes.
+ * @s: The cache we are working on.
+ */
+static void kmem_cache_balance_nodes(struct kmem_cache *s)
+{
+	struct kmem_cache_node *n = get_node(s, 0);
+	unsigned long desired_nr_slabs_per_node;
+	unsigned long nr_slabs;
+	int nr_nodes = 0;
+	int nid;
+
+	(void)kmem_cache_move_to_node(s, 0);
+
+	for_each_node_state(nid, N_NORMAL_MEMORY)
+		nr_nodes++;
+
+	nr_slabs = atomic_long_read(&n->nr_slabs);
+	desired_nr_slabs_per_node = nr_slabs / nr_nodes;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		if (nid == 0)
+			continue;
+
+		kmem_cache_move_slabs(s, 0, nid, desired_nr_slabs_per_node);
+	}
+}
 #endif
 
 /**
@@ -5838,6 +5941,22 @@ static ssize_t move_store(struct kmem_cache *s, const char *buf, size_t length)
 	return length;
 }
 SLAB_ATTR(move);
+
+static ssize_t balance_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+static ssize_t balance_store(struct kmem_cache *s,
+			     const char *buf, size_t length)
+{
+	if (buf[0] == '1')
+		kmem_cache_balance_nodes(s);
+	else
+		return -EINVAL;
+	return length;
+}
+SLAB_ATTR(balance);
 #endif	/* CONFIG_SMO_NODE */
 
 #ifdef CONFIG_NUMA
@@ -5966,6 +6085,7 @@ static struct attribute *slab_attrs[] = {
 	&shrink_attr.attr,
 #ifdef CONFIG_SMO_NODE
 	&move_attr.attr,
+	&balance_attr.attr,
 #endif
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
-- 
2.21.0

