Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CF5DC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 04:30:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF26720883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 04:30:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF26720883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FECA6B0007; Tue,  9 Apr 2019 00:30:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AF876B0008; Tue,  9 Apr 2019 00:30:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C5B36B000C; Tue,  9 Apr 2019 00:30:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C881F6B0007
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 00:30:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b34so11483144pld.17
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 21:30:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aZRCsChXF6RozXz3lALP+22GHRpyOuulCIr0ckS3XBY=;
        b=ZS58jx/ZdP1RLgxyBzUSDVCkNgaF9Wfm0T0sp/vLqq43ZBkzyBw9LhCA1R8iL4J4HJ
         3tfqxZTn3+SED7/S/DKd70YKNymtA/qlhJaOUbXVSxT0M/C3j795J8aSlpjwxbsJ8kyR
         JKDGR+wpmakjb7ygJeMIhCyvPwkExtHkbYvCDP96CqwrUDCqrIHeSAJxhsHT5ww2N4w/
         C1dZTGvQpV7TqueTkGwMHZQGQ18fCsHFztqF4Kn5DNLMrfeEbcUmfV90/Jlh/ZTICNkb
         8leGgfdbJajfhP35WFVgvTQ2Ob97lnOZQIcfS0fHZTRYjBUzdlqVq3Wmv1G0/vmIzGpe
         6dwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWERUYGcuR1q0HZDYmoT6D7GO0XyO3wZW1miBQmJwFeWMFfHwgx
	VorJggofQuPg/DQd4OOd9WRuqqWFIJZ+v0WJhQa6fNAIKyrpEtZkhBJNF4n5Fpz7qjnd033EXT+
	3cdq5G+qzbr18x03s+0YShO6lT+OsAsYxuWjvxeTdbaPHg9GvPBatM96Gutuo2Chrmg==
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr10153450pla.311.1554784245230;
        Mon, 08 Apr 2019 21:30:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmALYLCHAsBn83JJ3nNMRFXZyvwVbhSWqX/OHYmSAmotVBFeeEFH9Q38SI374ote4WeX+W
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr10153381pla.311.1554784244469;
        Mon, 08 Apr 2019 21:30:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554784244; cv=none;
        d=google.com; s=arc-20160816;
        b=eAHVGKDHWkFhuve3Ckxmm0AwdiSCMqwOe8/2f1RhOgV9sKTybUXM9+fLy5ZVbdGlMn
         KrmwFoxGRtansGliMb+93XWT6aJBZeywzRsUCBENpyJRhvnaW9/Rsyhb6E4rnxyX3Pjb
         g8qd0BacbymioOdf1kjlaB/ct9+5ppz0DIqLvBRdrV7EK6g3DdXG7IysSpYrlQEXE2Co
         djxxts18MLZwt6ffV+JOz7bgNYOvk23j/8HIQ1csXHO1fVP/kTZ0ZLWPZkhRoV1OpwIX
         IvSxzGisE5cL7jrLNWKYvzgJrohzjYu3ZDlzPc+m2dCxXXxKz+TwhDMBWJdiMuWeQecz
         WM3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=aZRCsChXF6RozXz3lALP+22GHRpyOuulCIr0ckS3XBY=;
        b=NHhdIAUWxYsNdCZ+bYK/1pL7fj7+jqFTaeFaoRuN43QYAFH1wrAFEMAR5SBpABVJh2
         TluM24/Vazz9t4+sE47qH0/wp8dS1FCpbZkZ7xhdJS8bNzT4kWYb/wGgtv0mkCT5htvV
         iJbhUw8ogwVeaRqouJTXRg5Rz49bQ2JPL6aZ+eZeSMO7Olgl38SV9JuqDSEf8yyznyor
         D7VXyYM9XyJFO52uhJDNxst+ULYXxcbCzwNQyMkpZ4OBoiasqGcpfJjQEqH2otnCKYVP
         L4HRU33sgsacbic3odZ743Gf7VO2UXBd1RfV1/0jKnTVn6ZLmx+voZ0Roo7014fYQ6JD
         Vufw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 14si27999218pgv.248.2019.04.08.21.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 21:30:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id A8EC8E26;
	Tue,  9 Apr 2019 04:30:43 +0000 (UTC)
Date: Mon, 8 Apr 2019 21:30:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: mhocko@suse.com, david@redhat.com, dan.j.williams@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-Id: <20190408213041.50350dac32ed315839c57e09@linux-foundation.org>
In-Reply-To: <20190408082633.2864-3-osalvador@suse.de>
References: <20190408082633.2864-1-osalvador@suse.de>
	<20190408082633.2864-3-osalvador@suse.de>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  8 Apr 2019 10:26:33 +0200 Oscar Salvador <osalvador@suse.de> wrote:

> arch_add_memory, __add_pages take a want_memblock which controls whether
> the newly added memory should get the sysfs memblock user API (e.g.
> ZONE_DEVICE users do not want/need this interface). Some callers even
> want to control where do we allocate the memmap from by configuring
> altmap.
> 
> Add a more generic hotplug context for arch_add_memory and __add_pages.
> struct mhp_restrictions contains flags which contains additional
> features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> currently) and altmap for alternative memmap allocator.
> 
> This patch shouldn't introduce any functional change.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug-fix

x86_64 allnoconfig:

In file included from ./include/linux/mmzone.h:744:0,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/umh.h:4,
                 from ./include/linux/kmod.h:22,
                 from ./include/linux/module.h:13,
                 from init/do_mounts.c:1:
./include/linux/memory_hotplug.h:353:11: warning: ‘struct mhp_restrictions’ declared inside parameter list will not be visible outside of this definition or declaration
    struct mhp_restrictions *restrictions);
           ^~~~~~~~~~~~~~~~

Fix this by moving the arch_add_memory() definition inside
CONFIG_MEMORY_HOTPLUG and moving the mhp_restrictions definition to a more
appropriate place.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memory_hotplug.h |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- a/include/linux/memory_hotplug.h~mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug-fix
+++ a/include/linux/memory_hotplug.h
@@ -54,6 +54,16 @@ enum {
 };
 
 /*
+ * Restrictions for the memory hotplug:
+ * flags:  MHP_ flags
+ * altmap: alternative allocator for memmap array
+ */
+struct mhp_restrictions {
+	unsigned long flags;
+	struct vmem_altmap *altmap;
+};
+
+/*
  * Zone resizing functions
  *
  * Note: any attempt to resize a zone should has pgdat_resize_lock()
@@ -101,6 +111,8 @@ extern void __online_page_free(struct pa
 
 extern int try_online_node(int nid);
 
+extern int arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions);
 extern u64 max_mem_size;
 
 extern bool memhp_auto_online;
@@ -126,16 +138,6 @@ extern int __remove_pages(struct zone *z
 
 #define MHP_MEMBLOCK_API               (1<<0)
 
-/*
- * Restrictions for the memory hotplug:
- * flags:  MHP_ flags
- * altmap: alternative allocator for memmap array
- */
-struct mhp_restrictions {
-	unsigned long flags;
-	struct vmem_altmap *altmap;
-};
-
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 		       struct mhp_restrictions *restrictions);
@@ -349,8 +351,6 @@ extern int walk_memory_range(unsigned lo
 extern int __add_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource);
-extern int arch_add_memory(int nid, u64 start, u64 size,
-			struct mhp_restrictions *restrictions);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
_

