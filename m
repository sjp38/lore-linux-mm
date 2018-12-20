Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9692AC43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E4A9218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="PfolZphx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E4A9218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C1828E0010; Thu, 20 Dec 2018 14:22:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69B0D8E0001; Thu, 20 Dec 2018 14:22:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 539988E0010; Thu, 20 Dec 2018 14:22:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 265B38E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:22:01 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so2961039qtb.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=tMJflD5NVJ4V9q8P29WkibQrcq00hjoERQHQ4TCQo7A=;
        b=q+U9e30pMG2MWjz29xtMQQHrpcR71IuRyWpFf0Ex1ctdE0e5NIn8TJqLqr8KyLa3Us
         q/1W7I++xepZzIJlfMV79vMoW1S0JIKBf0ewc0gqveAD6K8lBBDwT+IaBzxS00imlJz4
         tkCAwiYrqMdSIFy6V7FuVi9F57QYHFn2Gb1e1iyusA7lgf6xQtnkhngspEp/xiSoWgr4
         IHjP74yZ2ygDQyGN9YmAsL3k3MUtpqiEP5rw1wvTF36mGAwx4r5PsDo/u+GgKHW8WFsP
         hZWp2v2yVBvmAPYq4uq09cwsL5OCJ28IwAToBDWrWrBrLsBa8tTCzBtx8C2gQ/s2iOZq
         9M7Q==
X-Gm-Message-State: AA+aEWbh1AeBNglMwDuTL/Gj8F5qo0ZvUCAT7nqQv8MIuCEM83bDXTHv
	UoC9FukdOxf5FGHrJZmfGA82ImZwVooBzLOnDyyiNgeYWcf6PkkRk1kj0aRMGtPsZ06Jh5EZO0P
	31FTira2T9yWkHM77tqdRCpMyVmYHpe8h9U9h86JAXA3yjYx7oxd/pGBrKQKxHa0=
X-Received: by 2002:a37:8383:: with SMTP id f125mr25961902qkd.49.1545333720943;
        Thu, 20 Dec 2018 11:22:00 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WjydxmlaK8juwpKqFmnUwLM4TEysp5Er1Uuu4D26HwP1TawBQdZoSZ9XNIsOCe+HNXqVEk
X-Received: by 2002:a37:8383:: with SMTP id f125mr25961877qkd.49.1545333720455;
        Thu, 20 Dec 2018 11:22:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333720; cv=none;
        d=google.com; s=arc-20160816;
        b=nTfW7x5wPrBU86NGEoF3uvrGyxRMu66vNjZ1fzO3+OeQYxkHWASUkMY0sTzf1zLByl
         DwAEh4Xl4oJUVa6EoCrFGJjNvCniEa763qwunJRzU/7IDzJrAIJqidd8pCv16uMZWc2b
         HsprzvL0zQdhF8A4aLAXmebOVqtQTXTtsUEtbvtw8+Mkl50WxPSiKjKVNwkmnQrXDwB1
         z6I9QogkeetfIH/8tTegJOHsfkfzBtIEa9+nlhTA5f0kUU6zklcu2reehX9YKo7GUmWH
         xCrn78JmdmzvTX4h1uO/MkXelN8+CIKH8n7riIkO3d/kgFVownD72RSpwBIROVrU9dY8
         +Aig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=tMJflD5NVJ4V9q8P29WkibQrcq00hjoERQHQ4TCQo7A=;
        b=TwohWNKO1xj89mTonfNJ0IAOiaiy0vGZeH/wlQVV3g0GhLvYl9sBx3wsNQoi3XHkyh
         7igrhrmL01ipFCDPn3lpa9aK+8v9GwUie8aGY2Gjv8OIMVHtasaWx9f5VkvOiNbfbgmH
         Rj05ZXGGzS6w8ZX4yjUFd0BL0mLIfKSe1rrxSydnwmNRyca8yflQptE5Fu4YenBXq/TJ
         2+LDTlV+ZbwIHjilpI7qiZAB/NC4onHnuPT8fWc+PAH1nQXmiC1KI5izNCaVwApbmb9G
         kWPYLU45qXCnQ+DlxtSfHNBYHzHgD0kIBxIjGT5FKUHHTm14S/RWQs8GUMn/UH8F04hO
         5S9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=PfolZphx;
       spf=pass (google.com: domain of 01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id s188si603132qkh.260.2018.12.20.11.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:22:00 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=PfolZphx;
       spf=pass (google.com: domain of 01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333720;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=HPynk5ie8DqlrwTSrcpoX8ICqEk/Juei7kWbVieJc3U=;
	b=PfolZphxIyAKtwwsB+etH1iPIkc5vgB18IIUZeZFp+eNrdEkSPSxmjzp2/HrWYBD
	6jNi+e3ZPWy1bh34NwFCLIQXbD4VJEqXD6sowCDjyMi/oR/JGbPKLJ78ZjXGhVt4Prf
	+vNus1fbj5+deIsZuLLB5qaBnqanDwkpGAKDAHOo=
Message-ID:
 <01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:22:00 +0000
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
Subject: [RFC 4/7] slub: Sort slab cache list and establish maximum objects for defrag slabs
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=sort_and_max
X-SES-Outgoing: 2018.12.20-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192200.J0TdaYNSFhYaQ9co5eT-8BDJCMn_C_S1IVgCKjMjow8@z>

It is advantageous to have all defragmentable slabs together at the
beginning of the list of slabs so that there is no need to scan the
complete list. Put defragmentable caches first when adding a slab cache
and others last.

Determine the maximum number of objects in defragmentable slabs. This allows
the sizing of the array holding refs to objects in a slab later.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -196,6 +196,9 @@ static inline bool kmem_cache_has_cpu_pa
 /* Use cmpxchg_double */
 #define __CMPXCHG_DOUBLE	((slab_flags_t __force)0x40000000U)
 
+/* Maximum objects in defragmentable slabs */
+static unsigned int max_defrag_slab_objects;
+
 /*
  * Tracking user of a slab.
  */
@@ -4310,22 +4313,45 @@ int __kmem_cache_create(struct kmem_cach
 	return err;
 }
 
+/*
+ * Allocate a slab scratch space that is sufficient to keep at least
+ * max_defrag_slab_objects pointers to individual objects and also a bitmap
+ * for max_defrag_slab_objects.
+ */
+static inline void *alloc_scratch(void)
+{
+	return kmalloc(max_defrag_slab_objects * sizeof(void *) +
+		BITS_TO_LONGS(max_defrag_slab_objects) * sizeof(unsigned long),
+		GFP_KERNEL);
+}
+
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 	kmem_isolate_func isolate, kmem_migrate_func migrate)
 {
+	int max_objects = oo_objects(s->max);
+
 	/*
 	 * Defragmentable slabs must have a ctor otherwise objects may be
 	 * in an undetermined state after they are allocated.
 	 */
 	BUG_ON(!s->ctor);
+
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
+
 	/*
 	 * Sadly serialization requirements currently mean that we have
 	 * to disable fast cmpxchg based processing.
 	 */
 	s->flags &= ~__CMPXCHG_DOUBLE;
 
+	list_move(&s->list, &slab_caches);	/* Move to top */
+	if (max_objects > max_defrag_slab_objects)
+		max_defrag_slab_objects = max_objects;
+
+	mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_setup_mobility);
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -393,7 +393,7 @@ static struct kmem_cache *create_cache(c
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
 	if (err)

