Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11455C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 22:08:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB1F9206B8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 22:08:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r8eh4ERe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB1F9206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A88B6B0274; Tue,  4 Jun 2019 18:08:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2319E6B0276; Tue,  4 Jun 2019 18:08:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AD686B0277; Tue,  4 Jun 2019 18:08:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A96836B0274
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 18:08:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so2482245eda.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 15:08:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PpKRuZzE7T8mOmzox/3fZWCQGJE/CKE/yKMFRhJ3Gf8=;
        b=egdEfSZlQ8AW3BIH9yOlJMQoyPV1nNgAIl7i97eSGjKLReWtY6zlx3iiZPU7g3SIiw
         RT9ZwJ34OUOL6R94K2wIY7uVLxqCQWdFyy8Ga8xIp3kL14S9Rk+kEYxiVBk9nb4Nu9Md
         mwcWVEvtO92wup6nKrjwPISYsu4f3rY2c507FadPk/sGLNzZDM/cMgZzkswAbT6uqZfj
         3vgPgWughytE/8SsiIerNl0vMzP0HI9o7uX7hw0+FY4AHPp23RtSm46+/tPfL8cbarw6
         jLvrKKDob73qrKQIQmpiXOPluMFpJ8ltGfDypi6NaqfVkuIxCMcB4oVXoJ8+OcsAYXqM
         jmkA==
X-Gm-Message-State: APjAAAWYdFQ2ZA8lgRCKB19IIIhbpcCs3WEikaucJ605DpnGYiDmxGM2
	Z1gNVR2ppNlDycVZKxTw0BPVBv3+vjKe93FUKI39h4hiZtGcItmKRDaWIh3tS5Do3BiMFaqTyp6
	/Sq1y3cz2gMj1k2Cy5kIjzvJBvfHcLYc5vRs0Nog84Hc5tkcK48D5FQRhEYa94gTMqg==
X-Received: by 2002:a17:906:5586:: with SMTP id y6mr31304611ejp.120.1559686115124;
        Tue, 04 Jun 2019 15:08:35 -0700 (PDT)
X-Received: by 2002:a17:906:5586:: with SMTP id y6mr31299974ejp.120.1559686037423;
        Tue, 04 Jun 2019 15:07:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559686037; cv=none;
        d=google.com; s=arc-20160816;
        b=AEfEr+vwYkT5GJuYi4xp1TjVg80s/rkhP1PHd91EnskPuAKwR/trjwuw7h5raImrka
         gbCmCmzbZWLkAr9iQfPqaShD//f1HWrNGlFe2YHDA6fB18VZuJJoz1NOytnkHn4LAurK
         q23Xj0oi9kHWwuEnMIa8OdrQUjtETCTAqolHbKXFH43jrJthSkn7bOvA0vMi2+HXMcvw
         AElWOWdNjcDoMBoiEmaxY/AROHqlLSxkKSdNG4kaP4m/JYdtagSytSO+nfOWWGcw1wB+
         tKH2iWFRftvCMJ+hiplcUTb1BKBJj4eCms3f4tUinWISCdZ8iNBfLNHKm3CBhGZrgSfl
         lFdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=PpKRuZzE7T8mOmzox/3fZWCQGJE/CKE/yKMFRhJ3Gf8=;
        b=GjuoPAEbwXxhfEaiLmVH1RGAUjlvqVBPdHzIXOa7KsauXCaKgLGGw1uxowc66G2OSv
         pEVVtZ0ggN8Zhuz79znnBvdixcTG2sCebKyV6E8LSDEU+IDgUsZxbvs1Cl0z3j3zVClr
         1x/t/A2h/1J+O9EDZd9h8615Lakz6rNFaRBDr8ARMredpERnygiZvaqT3s4mcBggZGAr
         MlynV8F5ueG6xWdi47dYfWjYlqSS+PcR7onc2VO/AmiI0Uwd/rJTMdozKB+U5kc2Nwf0
         cvoDHfL0aR0hy+hvQXbxFSYBreYq6TPZKyOk3j1mwwKOxmbguIjyRqXzTfWwgHZgIcCo
         /lvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8eh4ERe;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w9sor980106edh.29.2019.06.04.15.07.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 15:07:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8eh4ERe;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PpKRuZzE7T8mOmzox/3fZWCQGJE/CKE/yKMFRhJ3Gf8=;
        b=r8eh4EReBOdbIPu4A1NNDGdXjFzs0/kcbitZHKKZAYaKNhXocwZblb/UDa/qHzpM4n
         H2elaGGk/e0gnNHPNwXKeHcAQnQ8whjG7luxPB1MehVQyRYd3L+0WhuLTmYgNONF0vQW
         /gT+d74vRjcqjUKUEja8QETsFhVds03K5SF2Vi+Gp28hsN/co8yAmDLlQo3XBDCsBx2t
         f10hoB3oefeCwKc/mwr3FNtMVXdQwW6jVfZhmt0IMWacdGBiHQOhNJfFHpgBzQfAMbQK
         Rzmp33l1qbOkzsE3obd4pS9v0hxJDLo8arS3ayyMB+ypJKFinJf8JyWlCou/md606BC2
         cf8w==
X-Google-Smtp-Source: APXvYqylJIv8N/2T6SjJp9NjY4VYtrcjtyg9w7oKoH7rUr1NCX7/8z5VGMCfO72kUy5fqWBqTC3/4A==
X-Received: by 2002:aa7:c3c9:: with SMTP id l9mr30726945edr.23.1559686037033;
        Tue, 04 Jun 2019 15:07:17 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id g18sm5036344edh.13.2019.06.04.15.07.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 15:07:16 -0700 (PDT)
Date: Tue, 4 Jun 2019 22:07:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
Message-ID: <20190604220715.d4d2ctwjk25vd5sq@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-10-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-10-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:50PM +0200, David Hildenbrand wrote:
>Let's factor out removing of memory block devices, which is only
>necessary for memory added via add_memory() and friends that created
>memory block devices. Remove the devices before calling
>arch_remove_memory().
>
>This finishes factoring out memory block device handling from
>arch_add_memory() and arch_remove_memory().
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Alex Deucher <alexander.deucher@amd.com>
>Cc: "David S. Miller" <davem@davemloft.net>
>Cc: Mark Brown <broonie@kernel.org>
>Cc: Chris Wilson <chris@chris-wilson.co.uk>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c  | 37 ++++++++++++++++++-------------------
> drivers/base/node.c    | 11 ++++++-----
> include/linux/memory.h |  2 +-
> include/linux/node.h   |  6 ++----
> mm/memory_hotplug.c    |  5 +++--
> 5 files changed, 30 insertions(+), 31 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 5a0370f0c506..f28efb0bf5c7 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -763,32 +763,31 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
> 	return ret;
> }
> 
>-void unregister_memory_section(struct mem_section *section)
>+/*
>+ * Remove memory block devices for the given memory area. Start and size
>+ * have to be aligned to memory block granularity. Memory block devices
>+ * have to be offline.
>+ */
>+void remove_memory_block_devices(unsigned long start, unsigned long size)
> {
>+	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>+	const int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
> 	struct memory_block *mem;
>+	int block_id;
> 
>-	if (WARN_ON_ONCE(!present_section(section)))
>+	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>+			 !IS_ALIGNED(size, memory_block_size_bytes())))
> 		return;
> 
> 	mutex_lock(&mem_sysfs_mutex);
>-
>-	/*
>-	 * Some users of the memory hotplug do not want/need memblock to
>-	 * track all sections. Skip over those.
>-	 */
>-	mem = find_memory_block(section);
>-	if (!mem)
>-		goto out_unlock;
>-
>-	unregister_mem_sect_under_nodes(mem, __section_nr(section));
>-
>-	mem->section_count--;
>-	if (mem->section_count == 0)
>+	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>+		mem = find_memory_block_by_id(block_id, NULL);
>+		if (WARN_ON_ONCE(!mem))
>+			continue;
>+		mem->section_count = 0;

Is this step necessary?

>+		unregister_memory_block_under_nodes(mem);
> 		unregister_memory(mem);
>-	else
>-		put_device(&mem->dev);
>-
>-out_unlock:
>+	}
> 	mutex_unlock(&mem_sysfs_mutex);
> }
> 
>diff --git a/drivers/base/node.c b/drivers/base/node.c
>index 8598fcbd2a17..04fdfa99b8bc 100644
>--- a/drivers/base/node.c
>+++ b/drivers/base/node.c
>@@ -801,9 +801,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
> 	return 0;
> }
> 
>-/* unregister memory section under all nodes that it spans */
>-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>-				    unsigned long phys_index)
>+/*
>+ * Unregister memory block device under all nodes that it spans.
>+ */
>+int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> {
> 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
> 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>@@ -816,8 +817,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> 		return -ENOMEM;
> 	nodes_clear(*unlinked_nodes);
> 
>-	sect_start_pfn = section_nr_to_pfn(phys_index);
>-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
>+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
> 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> 		int nid;
> 
>diff --git a/include/linux/memory.h b/include/linux/memory.h
>index db3e8567f900..f26a5417ec5d 100644
>--- a/include/linux/memory.h
>+++ b/include/linux/memory.h
>@@ -112,7 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
> extern int register_memory_isolate_notifier(struct notifier_block *nb);
> extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> int create_memory_block_devices(unsigned long start, unsigned long size);
>-extern void unregister_memory_section(struct mem_section *);
>+void remove_memory_block_devices(unsigned long start, unsigned long size);
> extern int memory_dev_init(void);
> extern int memory_notify(unsigned long val, void *v);
> extern int memory_isolate_notify(unsigned long val, void *v);
>diff --git a/include/linux/node.h b/include/linux/node.h
>index 1a557c589ecb..02a29e71b175 100644
>--- a/include/linux/node.h
>+++ b/include/linux/node.h
>@@ -139,8 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
> extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
> extern int register_mem_sect_under_node(struct memory_block *mem_blk,
> 						void *arg);
>-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>-					   unsigned long phys_index);
>+extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
> 
> extern int register_memory_node_under_compute_node(unsigned int mem_nid,
> 						   unsigned int cpu_nid,
>@@ -176,8 +175,7 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
> {
> 	return 0;
> }
>-static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>-						  unsigned long phys_index)
>+static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> {
> 	return 0;
> }
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 9a92549ef23b..82136c5b4c5f 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -520,8 +520,6 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
> 	if (WARN_ON_ONCE(!valid_section(ms)))
> 		return;
> 
>-	unregister_memory_section(ms);
>-
> 	scn_nr = __section_nr(ms);
> 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
> 	__remove_zone(zone, start_pfn);
>@@ -1845,6 +1843,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
> 	memblock_free(start, size);
> 	memblock_remove(start, size);
> 
>+	/* remove memory block devices before removing memory */
>+	remove_memory_block_devices(start, size);
>+
> 	arch_remove_memory(nid, start, size, NULL);
> 	__release_memory_resource(start, size);
> 
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

