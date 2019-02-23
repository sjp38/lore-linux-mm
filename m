Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7931BC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:09:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34DC42086A
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:09:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iW5dptGA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34DC42086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2C188E0141; Sat, 23 Feb 2019 16:09:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB41E8E009E; Sat, 23 Feb 2019 16:09:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 956BF8E0141; Sat, 23 Feb 2019 16:09:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 512AE8E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:09:43 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id z1so4615947pfz.8
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:09:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xM8Y7i9vim7KJCohLfRSf9EoimGxfe0FL1WmS7geoRY=;
        b=e8cCF/BQO0S3/rKTBHQ5VjFznK2KbiiFIzh0sLxeVLtBYAHNMp3EsrLDSzLpZIgdYw
         MIfIgbfj7YsDoMeEfM40YJXUz1RzsPgZOhU5ky3EuRTiAWULMDmSa/8VttocYTF+vLaU
         A75jIz/hcL7sRb08LP2LayO/8tR5eeYzvhd2UqTcOkKM4jN0pyckYDfU7IvqcpsH5AMU
         HzCrLubFCtEfj6PL2CZf0CWQGJTAHMLPKvYJNx7luEEnen0AMYGxIG/x7zFqwMTcB18s
         rSOQIKslQfkoAcZgHgtJ+Imo0xzHNsjOjuw+YI+Bo2i9yr7HvTJ0hsqIAuxeUvqiklJv
         nKmQ==
X-Gm-Message-State: AHQUAubdEHIvy1ymUtINbTnlvKZKmEmpafiTXZWMktdCcyN8s/eMkOhA
	0OgRAXno880GbFzBwcWkMLRPhsAA8ITBwiQEYNd0omGAnjlwtnacXMPYmWm0dPKDdd5padk5R0g
	rm6Lp0rpbAYuhNtLPe2JBvTTlzwJSA+LFFqZ+8q3z04r1iWusKZBz2VUSxdlPQCyKqw==
X-Received: by 2002:aa7:8597:: with SMTP id w23mr10758666pfn.87.1550956182994;
        Sat, 23 Feb 2019 13:09:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZLTUElHnf7RpyMm19cuWo/Xh92pYA50zL2VCiPTcR0P0wNoydyEjCBh41CtxgvZ7TLRRiY
X-Received: by 2002:aa7:8597:: with SMTP id w23mr10758617pfn.87.1550956182135;
        Sat, 23 Feb 2019 13:09:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956182; cv=none;
        d=google.com; s=arc-20160816;
        b=sA9d6c3cx14G4F6tFX+L4b91rTSlaPUTHj3Z5fQly7h21M3zyTF8phMiUQpKZIXV91
         nVIJGowoupH5ta/4CHe0B/ySNEUDzd5aZPos22IZZM6CT41i7zX2XqIujyIxMUI38NVN
         TeomyFxr3VaYMBV3G9sYx1f/ZqbtxjoyPiexWWewI2JpV7Z8kCtEHlF4Lx+/mXKSIngc
         rnQl9Uk89i9FyZm7oARDW1sAfRYgg0SNE+40SYfvi3rnDFTPkn/E1Qw3bz+V3JAVwTIB
         UUjxYUGTIsv3Yc2eagSv1R+HvgjbTulFOJ/YU6kETzmz5fUex1e6Esptn3F3EzUYKxr1
         cGCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xM8Y7i9vim7KJCohLfRSf9EoimGxfe0FL1WmS7geoRY=;
        b=pIOuRN5lUSoehFQn8abNAPCa3I4673UDX6wTMbcZjmHQswbd6KILLY4Y2kGaKdWUEv
         YsgK2bJc5RDDgQ9qzLoiVUH9IQls+RGCmCcq19npUyFpJcmv7zhh5GqUmXTfptO34mJc
         ANRobGPn0MemPp3x2oIJGQmWlClUOIvmaqoly5mAe4ZV2iFij1V2X5LEfchxEtQHLpw7
         wFW55GLQESNrqHX7GB84QAGAo9giedqoG7PpbD/V8EbzxKYK05vs5k6Ygs6bG8mb2xxR
         kEFehyIO4RMvyDO6ro2dnlfE8akyUD5NOSQxe3vavojlRkDjNhriBEVf86ehwbIwgKo6
         X9AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iW5dptGA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p11si4522087plk.191.2019.02.23.13.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:09:42 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iW5dptGA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A2EFA2086D;
	Sat, 23 Feb 2019 21:09:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956181;
	bh=r6BLaE0cmkHk9/RuvuLyrFwf/CvS0u2dXduPkRVYsyQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=iW5dptGAoe2dC+MFZyoIvhSbZ+wFukHe6q8R9vuAzABkjTT68ftBWOcGnkCPYm4iP
	 fgCIEMqtetfgDRQvaszFp56Fxolj1YXvtjnVmZ1HY9g5XZTQMkRQTZujfo8xp3+rIQ
	 N1XIHQn0EkY4jGMaFWX0ykIJemcAoLlDje/FDj1s=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 40/45] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Sat, 23 Feb 2019 16:08:30 -0500
Message-Id: <20190223210835.201708-40-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210835.201708-1-sashal@kernel.org>
References: <20190223210835.201708-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit efad4e475c312456edb3c789d0996d12ed744c13 ]

Patch series "mm, memory_hotplug: fix uninitialized pages fallouts", v2.

Mikhail Zaslonko has posted fixes for the two bugs quite some time ago
[1].  I have pushed back on those fixes because I believed that it is
much better to plug the problem at the initialization time rather than
play whack-a-mole all over the hotplug code and find all the places
which expect the full memory section to be initialized.

We have ended up with commit 2830bf6f05fb ("mm, memory_hotplug:
initialize struct pages for the full memory section") merged and cause a
regression [2][3].  The reason is that there might be memory layouts
when two NUMA nodes share the same memory section so the merged fix is
simply incorrect.

In order to plug this hole we really have to be zone range aware in
those handlers.  I have split up the original patch into two.  One is
unchanged (patch 2) and I took a different approach for `removable'
crash.

[1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
[2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
[3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz

This patch (of 2):

Mikhail has reported the following VM_BUG_ON triggered when reading sysfs
removable state of a memory block:

 page:000003d08300c000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
   is_mem_section_removable+0xb4/0x190
   show_mem_removable+0x9a/0xd8
   dev_attr_show+0x34/0x70
   sysfs_kf_seq_show+0xc8/0x148
   seq_read+0x204/0x480
   __vfs_read+0x32/0x178
   vfs_read+0x82/0x138
   ksys_read+0x5a/0xb0
   system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
   is_mem_section_removable+0xb4/0x190
 Kernel panic - not syncing: Fatal exception: panic_on_oops

The reason is that the memory block spans the zone boundary and we are
stumbling over an unitialized struct page.  Fix this by enforcing zone
range in is_mem_section_removable so that we never run away from a zone.

Link: http://lkml.kernel.org/r/20190128144506.15603-2-mhocko@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c7c74a927d6f8..39db89f3df657 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1256,7 +1256,8 @@ static struct page *next_active_pageblock(struct page *page)
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
-	struct page *end_page = page + nr_pages;
+	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
+	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-- 
2.19.1

