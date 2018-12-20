Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E558C43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3847218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="OHCLLzJ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3847218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BF278E000E; Thu, 20 Dec 2018 14:21:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E5D8E0001; Thu, 20 Dec 2018 14:21:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00D2C8E000E; Thu, 20 Dec 2018 14:21:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD8268E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:21:58 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so2914695qkb.6
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:21:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=Ivmf8KcU0nLZ7jKiUwDMxrV5SnY1/n4WH4SoklosWW0=;
        b=p494fjCXRBtmikzfY3fSg8Y97E3Tt5xTe/oV+Qa/3zJL48ikRl2afKvKtSf0JZYCb9
         M4DI1Cn2UxJTvu3SHMxIgHqKYyg7M4HPp7v5wXe/nbya6NfkIAYKMzkkS1R3NuqLAaFe
         UkTM+slRZkfr8193h6d/Sl/BnskaWrW4yIUVq1q4Wn5rZfQt9doc3OsuexpwRui80vxX
         XxtzArTIBplA5xvqkXpAoP8rI/c0JI45MlFlLbSEsrfSYaAnPX0OFuX4rWZON62DB2jX
         MR+Fu+CUaN//ki5LBYs95+s1FGZZgReKrNk8bfbSDO0vdh4w8gpZKdCgPNpo0jV0qNZ+
         xzyg==
X-Gm-Message-State: AA+aEWb0trggFIxrxdPadFKQwbfNA/jrej/KrEXnjMw8qcNX1oRZugwO
	/Bhs4erXvGyRvqcM+AdTVoG3UU2nYD+v1ujFyVUqtOxUHws+Tvpoejo10UZyxH0hy84oaDx+0Re
	lU8D/2vfTdXq453PZTbO5fTQJ8AYmuEW1DTeVL2M49HkqJhsFvlnYrBMZqObq0AU=
X-Received: by 2002:ad4:42d1:: with SMTP id f17mr27312337qvr.59.1545333718517;
        Thu, 20 Dec 2018 11:21:58 -0800 (PST)
X-Google-Smtp-Source: AFSGD/U6NTLTduKya/Jaj1UeeGKOzS/cg6mHz7sndzifOXZ+tyk+s21gMNcW0+MrrGhFiw40jr25
X-Received: by 2002:ad4:42d1:: with SMTP id f17mr27312314qvr.59.1545333718159;
        Thu, 20 Dec 2018 11:21:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333718; cv=none;
        d=google.com; s=arc-20160816;
        b=K6C2LCMlLa+tKqJjyssKFOl6ThH36Y6n+p4d/w1U7DOzrecCMoPjKbUYkwdScFNz2V
         E/NvO9RJFqofKclfj3ztGk807TrPp87agUJAVNChbcI6EHJd1ydvfsy7G3kFxodtL16Y
         VkA+I/vRDrfhluQ5utDoaoxN+uDpnyWlRZwO9KWNQfhPH7e1wXl2kfLdtIW8eyu0Ncy1
         yKR56w2FVmB92qVhuDtkeVg1avcnaJIh4uHseI+LVhjVSen0auZGP7ZPMU3hNFnFkFeq
         7600Sy+VcqjTifRFP1SoMXNcyZz2xYSA4cfbp72OCZtvE4hAy0e9JWyGYX20qCuQNVzi
         6EZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=Ivmf8KcU0nLZ7jKiUwDMxrV5SnY1/n4WH4SoklosWW0=;
        b=Uv4T0AYE91dfhCDv9iaBzaRzQ3teHdn90KHKQEtVNWFNbgfAN0I9QXz3QKsQJvbclI
         +ZTKSNJobF7q4Us7MNqrnJ7UoEYfGOq/cdO1dPBHFSk8lFYR31Z/k68sWGccGnyIPNCA
         OTItD7BodV/pZUoq4mg7b4GTga/07gFX3Jam2llA8zXQ4UC3f3sTdZmGZNbjQkVrKoZo
         0F501eCX/cDbawjCJ7KzD5b9UyWOilyVW6wA9eRq7NiaOtzdMcJNRJX/rF41TKSlY7z5
         uQOa6cOcTYogYqaohMvUhl92yYFDT/PT/3xarl04G1CnPPLnAV2YDQKvFp8dVf1943hu
         67iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=OHCLLzJ6;
       spf=pass (google.com: domain of 01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id u13si2533036qvp.212.2018.12.20.11.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:58 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=OHCLLzJ6;
       spf=pass (google.com: domain of 01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333717;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=9RbM/jvYgrX3laKFEpjCMiN+ksJv3eWbjUkCaqrfwkE=;
	b=OHCLLzJ6oPFtcW68XCABgoUNOPVk6+3UQC2JsdbyVQyPQYljUakQzjMHr+tVlzug
	2Vhpy7LZgA18mSKFfdg/iDG1ZWq+wKqvZZ43b68MiSQdWISkARuNc5UnrfGittJIxn7
	ZDgfT1On7RLQBhryQyuP+CQHfiloPZZBUn9hI4OU=
Message-ID:
 <01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:21:57 +0000
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
Subject: [RFC 2/7] slub: Add defrag_ratio field and sysfs support
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=defrag_ratio
X-SES-Outgoing: 2018.12.20-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192157.Gct4YEGtCvf0VlQ2qsr_rys9VrqLlZO63jL7QOd2CLM@z>

"defrag_ratio" is used to set the threshold at which defragmentation
should be attempted on a slab page.

"defrag_ratio" is percentage in the range of 1 - 100. If more than
that percentage of slots in a slab page are unused the the slab page
will become subject to defragmentation.

Add a defrag ratio field and set it to 30% by default. A limit of 30% specifies
that less than 3 out of 10 available slots for objects need to be leftover
before slab defragmentation will be attempted on the remaining objects.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 Documentation/ABI/testing/sysfs-kernel-slab |   13 +++++++++++++
 include/linux/slub_def.h                    |    6 ++++++
 mm/slub.c                                   |   23 +++++++++++++++++++++++
 3 files changed, 42 insertions(+)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3628,6 +3628,7 @@ static int kmem_cache_open(struct kmem_c
 
 	set_cpu_partial(s);
 
+	s->defrag_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -5113,6 +5114,27 @@ static ssize_t destroy_by_rcu_show(struc
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
+static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->defrag_ratio);
+}
+
+static ssize_t defrag_ratio_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	unsigned long ratio;
+	int err;
+
+	err = kstrtoul(buf, 10, &ratio);
+	if (err)
+		return err;
+
+	if (ratio < 100)
+		s->defrag_ratio = ratio;
+	return length;
+}
+SLAB_ATTR(defrag_ratio);
+
 #ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -5437,6 +5459,7 @@ static struct attribute *slab_attrs[] =
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_ratio_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
Index: linux/Documentation/ABI/testing/sysfs-kernel-slab
===================================================================
--- linux.orig/Documentation/ABI/testing/sysfs-kernel-slab
+++ linux/Documentation/ABI/testing/sysfs-kernel-slab
@@ -180,6 +180,19 @@ Description:
 		list.  It can be written to clear the current count.
 		Available when CONFIG_SLUB_STATS is enabled.
 
+What:		/sys/kernel/slab/cache/defrag_ratio
+Date:		December 2018
+KernelVersion:	4.18
+Contact:	Christoph Lameter <cl@linux-foundation.org>
+		Pekka Enberg <penberg@cs.helsinki.fi>,
+Description:
+		The defrag_ratio files allows the control of how agressive
+		slab fragmentation reduction works at reclaiming objects from
+		sparsely populated slabs. This is a percentage. If a slab
+		has more than this percentage of available object then reclaim
+		will attempt to reclaim objects so that the whole slab
+		page can be freed. The default is 30%.
+
 What:		/sys/kernel/slab/cache/deactivate_to_tail
 Date:		February 2008
 KernelVersion:	2.6.25
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h
+++ linux/include/linux/slub_def.h
@@ -104,6 +104,12 @@ struct kmem_cache {
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
+	int defrag_ratio;	/*
+				 * Ratio used to check the percentage of
+				 * objects allocate in a slab page.
+				 * If less than this ratio is allocated
+				 * then reclaim attempts are made.
+				 */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 	struct work_struct kobj_remove_work;

