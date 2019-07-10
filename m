Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4199C73C63
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E3212064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="LntS6yWp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E3212064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 906008E0063; Tue,  9 Jul 2019 21:16:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DD3A8E0032; Tue,  9 Jul 2019 21:16:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7574B8E0063; Tue,  9 Jul 2019 21:16:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 553F88E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 21:16:54 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r58so790368qtb.5
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 18:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=oUgTnAZaywklydAAAPvB3a6I5/R1cYvy+iIkRwSNZnk=;
        b=F2OmTC+Buy/CBkWanuVllpngI1fvUzNI6Mp8Nbw1e3iShLW/8PmThXWhzEkDpHII/P
         nfmD/qpwGiGAt/Xqi7ACClbJazO2TpAw1Cd99iCDwiM2/IUPeWNiUnpUee7KrUICOK2E
         0Yu6SZ7G4LZZj6FJHvRZJj2L2K9s6H0ZzntEVDzG9/PfcoHkhwwQu8V2oS03mpNHAhTP
         QSv6YVXbr+X8YmRQ4JPUh35tf4CZZdD2MVSTRN2QtqCEUJBfTh86f4Lx1cqbwtEBUIEV
         7z+hysKzy67A9YqEQeJMaFqVaaPBWGSnlkgad8fljPCw8skvJkB4rSMk5ATkYsvXc2vk
         zIhg==
X-Gm-Message-State: APjAAAXYyGKhqsaFbIBi+q6mM2jWuC8KhAk+3auDWEYQhQCbx+Y4gJ+d
	64IOpbxl5AagVeabW5Gdz5QJDN0beUmnrUxVYE1wES2FVF8MiWg1rexT9oTXXtcqevSftof2Ueu
	J4e6dID240lgssS9ugHrZqyXBfuifX59ze6oOTaHAU/tjuhPlkRswyPveDvSEpIJbhQ==
X-Received: by 2002:a0c:e001:: with SMTP id j1mr22236035qvk.110.1562721414079;
        Tue, 09 Jul 2019 18:16:54 -0700 (PDT)
X-Received: by 2002:a0c:e001:: with SMTP id j1mr22235981qvk.110.1562721412964;
        Tue, 09 Jul 2019 18:16:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562721412; cv=none;
        d=google.com; s=arc-20160816;
        b=TR/oUmwmpb5hjopLpv7llAc7bdSePoRNcYR2xl29qw+kk5Bjx3kWSN770WtilS3JLJ
         ld3ScER9puBufQOErajUWEqk1BW1ZX3b60sqPXBeNhQt6e9UWj5ZZ9gJMHdO7Bgb4CRP
         ILclwCdo5gPiprBrFvXBtVHElP/1sdaT5hG8DKvhnwp0GXx3ApQVcrNlu71XSPqlLhBm
         2U6AKGI3kOTf22SUWJJ0d2b4wRt9eTHsUmfQnBdr5DRglT5ptYHI1fiH98ud62bqskC8
         rmyedVBpGY2TRRpSJ8n8npvJAXAc81v0LpZqQnY8XBooEA94Thoxo1rvN34qQc4EcmhQ
         t65A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=oUgTnAZaywklydAAAPvB3a6I5/R1cYvy+iIkRwSNZnk=;
        b=K4Ml9PVby2bZ8DzbMA5gxn20+DeRkMXREIEBnLXLGMAFcAPnGgrVbANCR+2daLgZ5E
         7k/OYCdEIobt3MQcMXNfke1qT6jz62EP2f3Xepi4ug9iocWHkIfZnOdH7EvMKGusXBdk
         RTiAWuK+oLBiGf7eV9wYQ2kAp5Fg7/uQfeV7WK2skUIERaOX71v5h3gVgLBwoqM08dal
         eYehGJD8OZJBXmDTOJaqgPazLFZYaOFlUpcSeC2Z36bfPDMtBoe0vyHkEyZP1HcyPEAV
         MOcGbtvtbfwebBkdLkvVIqO75S0bDtgh3aa11V8hlBxw6uopOxl3j89xViKftJkmjCgZ
         sa/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=LntS6yWp;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p184sor256278qkc.123.2019.07.09.18.16.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 18:16:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=LntS6yWp;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oUgTnAZaywklydAAAPvB3a6I5/R1cYvy+iIkRwSNZnk=;
        b=LntS6yWpaejTt9SVF+fVC7Ci+89fr1DyTiF2xUKIH6h5NkvSH1k381FHUeqUUuEcc0
         yTUCL82/lOdUkkiALPPXLeGUGi+WKdtti/fdXv7kou9x3YPyBEwjVcIl7USaCoXIZFUA
         fh2Y3StdFNp2P+hUfdI7X47L0fnYYCJ6Q27PFiFAX3EL6BnWqkIs1WJrholKT3m0OGvh
         QoQh/R6z6Axr1Gsk8qhhISOsyPX5mxP1AaJiB9yX8iBQS+y1DZqdo7yTBfxDyRPYS/HN
         y+M1N36aWpeympdukvQFHHSKXlVWGprnTISAipceqCsdtGqIPYS/cmxeFKXBruxe+2u5
         JQ8A==
X-Google-Smtp-Source: APXvYqyayfanR0LhFsg7XP0bJdPSuQa2GB1LgirxNwXiGmy32bzFbJzapk8lj3SFV7YobHsyO98cKQ==
X-Received: by 2002:a37:4c4e:: with SMTP id z75mr21389763qka.230.1562721412692;
        Tue, 09 Jul 2019 18:16:52 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u7sm260057qta.82.2019.07.09.18.16.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 09 Jul 2019 18:16:52 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v7 2/3] mm/hotplug: make remove_memory() interface useable
Date: Tue,  9 Jul 2019 21:16:46 -0400
Message-Id: <20190710011647.10944-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190710011647.10944-1-pasha.tatashin@soleen.com>
References: <20190710011647.10944-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As of right now remove_memory() interface is inherently broken. It tries
to remove memory but panics if some memory is not offline. The problem
is that it is impossible to ensure that all memory blocks are offline as
this function also takes lock_device_hotplug that is required to
change memory state via sysfs.

So, between calling this function and offlining all memory blocks there
is always a window when lock_device_hotplug is released, and therefore,
there is always a chance for a panic during this window.

Make this interface to return an error if memory removal fails. This way
it is safe to call this function without panicking machine, and also
makes it symmetric to add_memory() which already returns an error.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memory_hotplug.h |  8 +++--
 mm/memory_hotplug.c            | 64 +++++++++++++++++++++++-----------
 2 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..988fde33cd7f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -324,7 +324,7 @@ static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
 extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
-extern void remove_memory(int nid, u64 start, u64 size);
+extern int remove_memory(int nid, u64 start, u64 size);
 extern void __remove_memory(int nid, u64 start, u64 size);
 
 #else
@@ -341,7 +341,11 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	return -EINVAL;
 }
 
-static inline void remove_memory(int nid, u64 start, u64 size) {}
+static inline int remove_memory(int nid, u64 start, u64 size)
+{
+	return -EBUSY;
+}
+
 static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e096c987d261..77d1f69cdead 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1736,9 +1736,10 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
 		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
 			&beginpa, &endpa);
-	}
 
-	return ret;
+		return -EBUSY;
+	}
+	return 0;
 }
 
 static int check_cpu_on_node(pg_data_t *pgdat)
@@ -1821,19 +1822,9 @@ static void __release_memory_resource(resource_size_t start,
 	}
 }
 
-/**
- * remove_memory
- * @nid: the node ID
- * @start: physical address of the region to remove
- * @size: size of the region to remove
- *
- * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
- * and online/offline operations before this call, as required by
- * try_offline_node().
- */
-void __ref __remove_memory(int nid, u64 start, u64 size)
+static int __ref try_remove_memory(int nid, u64 start, u64 size)
 {
-	int ret;
+	int rc = 0;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
@@ -1841,13 +1832,13 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
-	 * whether all memory blocks in question are offline and trigger a BUG()
+	 * whether all memory blocks in question are offline and return error
 	 * if this is not the case.
 	 */
-	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
-				check_memblock_offlined_cb);
-	if (ret)
-		BUG();
+	rc = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
+			       check_memblock_offlined_cb);
+	if (rc)
+		goto done;
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
@@ -1859,14 +1850,45 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	try_offline_node(nid);
 
+done:
 	mem_hotplug_done();
+	return rc;
 }
 
-void remove_memory(int nid, u64 start, u64 size)
+/**
+ * remove_memory
+ * @nid: the node ID
+ * @start: physical address of the region to remove
+ * @size: size of the region to remove
+ *
+ * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
+ * and online/offline operations before this call, as required by
+ * try_offline_node().
+ */
+void __remove_memory(int nid, u64 start, u64 size)
+{
+
+	/*
+	 * trigger BUG() is some memory is not offlined prior to calling this
+	 * function
+	 */
+	if (try_remove_memory(nid, start, size))
+		BUG();
+}
+
+/*
+ * Remove memory if every memory block is offline, otherwise return -EBUSY is
+ * some memory is not offline
+ */
+int remove_memory(int nid, u64 start, u64 size)
 {
+	int rc;
+
 	lock_device_hotplug();
-	__remove_memory(nid, start, size);
+	rc  = try_remove_memory(nid, start, size);
 	unlock_device_hotplug();
+
+	return rc;
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-- 
2.22.0

