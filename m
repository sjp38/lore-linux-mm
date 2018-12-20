Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E621FC43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6EB520811
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="SCvVL+ju"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6EB520811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7998E0015; Thu, 20 Dec 2018 14:22:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 208938E0001; Thu, 20 Dec 2018 14:22:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A6BE8E0015; Thu, 20 Dec 2018 14:22:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFACB8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:22:04 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so2981832qte.0
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=w1fmM/A7/dLGujgt4qj/eIcE2IM8trq03+WjkP6rwKM=;
        b=T33Wz0r5W+e2s7P/AgDFB1dXKWpfRPqWvdZqnz6+sMy+j4quY3PR2uqb7SUNjbDUMK
         3nkC9VmVMYy8CKk+br5wz3kF2QiTdPMxXpFCOfqghacXOqu8IVOxHXSUIeTQgNYW/ozA
         inVTOgB2GLDe7Q4JVr1/yvBL/5HwCQQZK/3LcPALvYF954AdhcTz0LOAQF0a6aIbe0id
         2Jli6kqok47u5iKCVeLjNVp7LdHOYlBo03VfnQukWjZm1RbVTdj6xBsxsfqrmPu39Ulp
         GxKq28Nv7+KrN8jeCejlDyUysXJSgQv51VGik/sPJmq8oNSFaSoCfsTg2DZk2SPesaXD
         73DA==
X-Gm-Message-State: AA+aEWaW7/1XZR7IpYNVaK3pEMBsxGFc1lJz9lQwwZ8qvGgaLYXt2uRU
	GMKiRBl0897D7JxoOSHJGorx0a5ARd338SFanzKAFZH0nYOvIsanbfxr/a5sx6ANrHqJBMySmqQ
	zS78LXM1OPsKkEQO/Lu3y+UfzsFUgdyn+DoJdoHqREDG4R3IzP3v3xJhbSen004Y=
X-Received: by 2002:ac8:518d:: with SMTP id c13mr26615120qtn.254.1545333724613;
        Thu, 20 Dec 2018 11:22:04 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VelJAVgYE52SpK3mSrDBa59Ay/Yl3QeC++v5OJ6ioEeEBN0h6sEsDeYKte3Hl80l/ZCX+c
X-Received: by 2002:ac8:518d:: with SMTP id c13mr26615105qtn.254.1545333724269;
        Thu, 20 Dec 2018 11:22:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333724; cv=none;
        d=google.com; s=arc-20160816;
        b=YdfSJZ7QRTpUZYyA8pzb4TqP/K86QiLe2mVtzbL7yNwlf9qEH/KBhhzivBEedTURTA
         JFPzdr1+yJn678svy8Cur4hytWrb1RGe2r5RZpCt9G0hTgaWwEVjthuw8+ZBDyrXgB12
         wDtqve67y59tlJm662yAcEEmBX9XxMGYxGiPpaU2gbjMQfdwnpAEqgDYmtqdkWPC51jC
         8ylWeYwt8wd1NBDGZQz8A8icpQOwYc8AMC2Bw4ogDWE+p2/hNJ0h4tdb4qe7zmaPAUZ4
         ahQCxcIgq/7hDqQQak+gESavn92JIwir/da6Zm+5W0RRGykwy0QkEXXRUsD/vGWni0Y7
         6S+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=w1fmM/A7/dLGujgt4qj/eIcE2IM8trq03+WjkP6rwKM=;
        b=K5QYwOpz7FOYaP6HqB+VsXIGzADkSln0uixUBGJy+A+MjstFJe7gU65mNxJrnns88R
         ocedsguk2D4j6Y8sPayXzclvqQQWK0gOwNe2fyNCK/vVbXyxlDMVi6QnY5hMc7ecRn+X
         f/Q/jz+JAyKvNfGG0cnfUumcUWptbiQgagyz51evn6th8J5MwuWSZd6RgQHaJWUcy1wq
         DPfjtPp+ENFwBcq1Bx38Pcs38NheW/RNZRjtkrR7/lKc/uxtIJVYR5qn0CyZbpK2lJkE
         cta+0KOm7MJx43LxOFJaI8CNUXXheKnYwpoiG88nWfTlejPaH6huYtnSmrn41G/0JOjq
         ++QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=SCvVL+ju;
       spf=pass (google.com: domain of 01000167cd11517f-f122b002-1a61-46c9-af1a-5c7cf01a397d-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000167cd11517f-f122b002-1a61-46c9-af1a-5c7cf01a397d-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id l2si4247657qtj.22.2018.12.20.11.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:22:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd11517f-f122b002-1a61-46c9-af1a-5c7cf01a397d-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=SCvVL+ju;
       spf=pass (google.com: domain of 01000167cd11517f-f122b002-1a61-46c9-af1a-5c7cf01a397d-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000167cd11517f-f122b002-1a61-46c9-af1a-5c7cf01a397d-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333723;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=qNdEXLooQmyJC8nAB/4MyBKqNpzM7jv1JHGkgte2EEs=;
	b=SCvVL+juPo8Ksu9+O0sk/r8AiUR8JGnyzXhP7mYdvc3cEQ0ulPEhnt+VLcPLe1mc
	smDDyDaYkQ6dcwgZE1Tk0m8tUHdSf90cH0en+w2zBJBvdu+bFjmIMne/tJlZiqGphRG
	85bQcTIpVPEKivVme9DnvBzP1GZjcA05QzDioYdE=
Message-ID:
 <01000167cd11517f-f122b002-1a61-46c9-af1a-5c7cf01a397d-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:22:03 +0000
From: Christoph Lameter <cl@linux.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
CC: akpm@linux-foundation.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 7/7] xarray: Implement migration function for objects
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=xarray
X-SES-Outgoing: 2018.12.20-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192203.70Crds-2UrzpNa29pthTDucfoL-kSCMDEPUTyKzB1p4@z>

Implement functions to migrate objects. This is based on
initial code by Matthew Wilcox and was modified to work with
slab object migration.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/lib/radix-tree.c
===================================================================
--- linux.orig/lib/radix-tree.c
+++ linux/lib/radix-tree.c
@@ -1613,6 +1613,18 @@ static int radix_tree_cpu_dead(unsigned
 	return 0;
 }
 
+
+extern void xa_object_migrate(void *tree_node, int numa_node);
+
+static void radix_tree_migrate(struct kmem_cache *s, void **objects, int nr,
+		int node, void *private)
+{
+	int i;
+
+	for (i=0; i<nr; i++)
+		xa_object_migrate(objects[i], node);
+}
+
 void __init radix_tree_init(void)
 {
 	int ret;
@@ -1627,4 +1639,7 @@ void __init radix_tree_init(void)
 	ret = cpuhp_setup_state_nocalls(CPUHP_RADIX_DEAD, "lib/radix:dead",
 					NULL, radix_tree_cpu_dead);
 	WARN_ON(ret < 0);
+	kmem_cache_setup_mobility(radix_tree_node_cachep,
+					NULL,
+					radix_tree_migrate);
 }
Index: linux/lib/xarray.c
===================================================================
--- linux.orig/lib/xarray.c
+++ linux/lib/xarray.c
@@ -1934,6 +1934,51 @@ void xa_destroy(struct xarray *xa)
 }
 EXPORT_SYMBOL(xa_destroy);
 
+void xa_object_migrate(struct xa_node *node, int numa_node)
+{
+	struct xarray *xa = READ_ONCE(node->array);
+	void __rcu **slot;
+	struct xa_node *new_node;
+	int i;
+
+	/* Freed or not yet in tree then skip */
+	if (!xa || xa == XA_FREE_MARK)
+		return;
+
+	new_node = kmem_cache_alloc_node(radix_tree_node_cachep, GFP_KERNEL, numa_node);
+
+	xa_lock_irq(xa);
+
+	/* Check again..... */
+	if (xa != node->array || !list_empty(&node->private_list)) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	/* Move pointers to new node */
+	INIT_LIST_HEAD(&new_node->private_list);
+	for (i = 0; i < XA_CHUNK_SIZE; i++) {
+		void *x = xa_entry_locked(xa, new_node, i);
+
+		if (xa_is_node(x))
+			rcu_assign_pointer(xa_to_node(x)->parent, new_node);
+	}
+	if (!new_node->parent)
+		slot = &xa->xa_head;
+	else
+		slot = &xa_parent_locked(xa, new_node)->slots[new_node->offset];
+	rcu_assign_pointer(*slot, xa_mk_node(new_node));
+
+unlock:
+	xa_unlock_irq(xa);
+	xa_node_free(node);
+	rcu_barrier();
+	return;
+
+}
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {

