Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7380C282CE
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 05:59:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E8DB20693
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 05:59:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E8DB20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29EAA6B0005; Sun, 14 Apr 2019 01:59:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2283E6B0006; Sun, 14 Apr 2019 01:59:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A2036B0008; Sun, 14 Apr 2019 01:59:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACF096B0005
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 01:59:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so7232722eda.10
        for <linux-mm@kvack.org>; Sat, 13 Apr 2019 22:59:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=pXwTSUlqonpPBE1Ovkstllk7lYSjhD8ZYJok0AGWG+E=;
        b=RHKaWasJ/f+mJXuIzDiV1y7QGS5ct+ZT+4F2NFv27fQ2QS2PCakSwNX2bjgLLDfGqU
         5aniQrqpRRodle137wHac7TqiDehnKvzXrSOGC7R/GrPvpcAhIHWTTRHrtxwHjvQMPsV
         p2uiJaU9bMgmqCU4mGRAQEI6IwBg/u2rkATyaRyswnF7w8MGl5ukJcZ2ioUw5aNIcs+I
         L8LitnkfxUSWImhBHDc7WpB0XvmBxuE/cfGPzN/uLuZNNRYSgGilvOH+0Sro/LTLy55x
         0skmpkt/tK5UM5L7ieA/A5l/KJVNFbHkdGu7rt3p64kShaNtBj9v2cFaStxr+zNuaCnW
         yfkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWTmEXMFK68975htiFSKEN6MuVFwuIKYa4jTTHHwn/WB9cZZR4h
	Zp46qyW6ej7cOSCcO73UdOz0lD9GoKOAM214+Gp7yuj6J9Eoi2vNbSQLRbXKWNC1rt0iGzDEVVu
	HOFYpYTR4PVI3O5yh4nQ3tqEiCD4v4HFcSedbGD/DV0lOXqT9RBzW/i8eWNySmnhEwg==
X-Received: by 2002:a17:906:1545:: with SMTP id c5mr37195232ejd.135.1555221576100;
        Sat, 13 Apr 2019 22:59:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5rPIdoR0yUNL2B5gWMHMwyEkM6peJeQ5FHTntQ1MM/G72qm79w6z3onobkh5YFgV6aYS/
X-Received: by 2002:a17:906:1545:: with SMTP id c5mr37195192ejd.135.1555221574872;
        Sat, 13 Apr 2019 22:59:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555221574; cv=none;
        d=google.com; s=arc-20160816;
        b=nhyrt5iQvzUvHELTOzrIdjeruDmCdpjDztOZZ6vxG8q1rCuORGw/58FfniZm3JZiLL
         Pdnjepkzuf8CcSBFUgnXHbWREDRQhj+P2XNNwXffUM8ylCRLewR2nZ6e8Ef9/nIhM90S
         GB291fGITgDfJMsL33pDQz8qjXamZkpsJRqmfllYYObjdte0oIk83c//CHf8hQkIPine
         3ohsp51bWxLTtjYnOO2tPKls5glAiJY1dKkv2QLE6zNvS29s8f0AHtTiqzMeXvRgOJUU
         zQVl1JNBWy0Zc0njnztcoOWm2qCnfsw99WEBXpA+HZ8NJoO7PzKUZL6AlKmoqGK4mP5m
         p+Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=pXwTSUlqonpPBE1Ovkstllk7lYSjhD8ZYJok0AGWG+E=;
        b=GGv+Ey4AUa2bXxGeobdOeCtuV9UhYjd8ML9PRMcfe2Jf+ISDBSh/Yuw6+22TthaQz7
         hH5P/bka9Sl1x7u86j0WJ1ydA5xS03vx2VVtKoslNZMnzGN3CkpiHD9k9Cv6yPAwPYRc
         U3znjNsprlA0nNTeNQ7tDMAUx42daIjwmQ78Wpnz+Yp9HdA4DYO6UV7QwvyEEEbgK0OZ
         IkhtJzhX8H7lTSYPDgU5YEhalgVz/YNJyIOardjrdEg3fo6r4ojk2rtAaYZkUjqUfmJz
         QofXIs4Sbfsdn0RXpjuuEehNL5dYhdHCBlAbs2efdahWnEhczZvpW2iixpRd2CTZ6Y1n
         G2fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h44si823989ede.156.2019.04.13.22.59.34
        for <linux-mm@kvack.org>;
        Sat, 13 Apr 2019 22:59:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ABA6015AD;
	Sat, 13 Apr 2019 22:59:33 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 5496E3F557;
	Sat, 13 Apr 2019 22:59:28 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	ira.weiny@intel.com
Subject: [PATCH V2 1/2] mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
Date: Sun, 14 Apr 2019 11:29:12 +0530
Message-Id: <1555221553-18845-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
entries between memory block and node. It first checks pfn validity with
pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
(arm64 has this enabled) pfn_valid_within() calls pfn_valid().

pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
which scans all mapped memblock regions with memblock_is_map_memory(). This
creates a problem in memory hot remove path which has already removed given
memory range from memory block with memblock_[remove|free] before arriving
at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
of existing sysfs entries.

[   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
[   62.052517] ------------[ cut here ]------------
[   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
[   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   62.054589] Modules linked in:
[   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
[   62.056274] Hardware name: linux,dummy-virt (DT)
[   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
[   62.058083] pc : add_memory_resource+0x1cc/0x1d8
[   62.058961] lr : add_memory_resource+0x10c/0x1d8
[   62.059842] sp : ffff0000168b3ce0
[   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
[   62.061501] x27: 0000000000000000 x26: 0000000000000000
[   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
[   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
[   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
[   62.065558] x19: 0000000000680000 x18: 0000000000000024
[   62.066566] x17: 0000000000000000 x16: 0000000000000000
[   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
[   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
[   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
[   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
[   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
[   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
[   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
[   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
[   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
[   62.076930] Call trace:
[   62.077411]  add_memory_resource+0x1cc/0x1d8
[   62.078227]  __add_memory+0x70/0xa8
[   62.078901]  probe_store+0xa4/0xc8
[   62.079561]  dev_attr_store+0x18/0x28
[   62.080270]  sysfs_kf_write+0x40/0x58
[   62.080992]  kernfs_fop_write+0xcc/0x1d8
[   62.081744]  __vfs_write+0x18/0x40
[   62.082400]  vfs_write+0xa4/0x1b0
[   62.083037]  ksys_write+0x5c/0xc0
[   62.083681]  __arm64_sys_write+0x18/0x20
[   62.084432]  el0_svc_handler+0x88/0x100
[   62.085177]  el0_svc+0x8/0xc

Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
problem on arm64 as pfn_valid() behaves correctly and returns positive
as memblock for the address range still exists. arch_remove_memory()
removes applicable memory sections from zone with __remove_pages() and
tears down kernel linear mapping. Removing memblock regions afterwards
is safe because there is no other memblock (bootmem) allocator user that
late. So nobody is going to allocate from the removed range just to blow
up later. Also nobody should be using the bootmem allocated range else
we wouldn't allow to remove it. So reordering is indeed safe.

Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/memory_hotplug.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0082d69..71d0d79 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1872,11 +1872,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
+	arch_remove_memory(nid, start, size, NULL);
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(nid, start, size, NULL);
-
 	try_offline_node(nid);
 
 	mem_hotplug_done();
-- 
2.7.4

