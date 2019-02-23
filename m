Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D386BC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F0112086C
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:11:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vfwuxtJ7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F0112086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38B528E0152; Sat, 23 Feb 2019 16:11:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 360808E009E; Sat, 23 Feb 2019 16:11:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24FC38E0152; Sat, 23 Feb 2019 16:11:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D634C8E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:11:27 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x23so1075841pfm.0
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:11:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LzU8Bo5iest5jchhiQ8SOcdIrjdY2O1BrERsQgbTOr0=;
        b=fD0lPDYW3Dh9VYUo27Tu2/2igka3+ddY3Lkg7aC5swqtAGvdfaD9lnMfgeOhLAV6sY
         rhEOhkNGFFmnTSreCEBUy/igApgg16odQ1x+mYR5qzCNJlSE1IBgFwE+KYODbPhXFIzL
         +1nyh5m4b8T6h4u7F+fFegax0nwFGdn6xUe60zVYhIyG8WUeCpib13ZRV+7Q9Uys73VA
         CYerT5XwmFhYXVLUtl4GVH+Bv9yTC0km4ERYZ/HZ0DtUON9Rx7gpwqGj96yqRr3AwlJJ
         0Wv5qbk+04DYEQUWcwn4bOPGqjWxYMvxDcZcPOwTOsZoNaQYPI5vVW1SQa2dgygtltsS
         AvYw==
X-Gm-Message-State: AHQUAublEHMajO9gV3UUUQXODuOVPY9mFb2B7OZ3IgWaYtub5viafkWh
	mVI7wZ9abYyvzGPzzD92SYkrRtl7IyHnW6IYEtuta5W5DMgC5y5zMxr/WV35djBEB4j05O2ha6b
	Gs0o9AJTlRKX0fgY4Y67EJtm6zLmnvjF5OUW5sonKHiUezfgGu4C1GJk/NCFxXMm22Q==
X-Received: by 2002:a17:902:8b83:: with SMTP id ay3mr10532606plb.1.1550956287516;
        Sat, 23 Feb 2019 13:11:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhsN5+aayN4Awe43Sbh7VJpo42zO8v1bWiw0DEfh4ZfGsEkZ994lQzM3MuI19fBlb1GHXS
X-Received: by 2002:a17:902:8b83:: with SMTP id ay3mr10532564plb.1.1550956286794;
        Sat, 23 Feb 2019 13:11:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956286; cv=none;
        d=google.com; s=arc-20160816;
        b=nMk3sVcJk9RdBQtFme7ILSrc2USpLm9RMgjSkGfrXi8g3V7xh2n/hgRAH01z6QUnsT
         RcQ7WlYcuKQG2BwFLedCOtboIsHM0NPYayAJr1gvwsrXF1OQgMxne+Bdu19n2OgKAs1C
         HRsurnoBeU8DCuy05cpOxV5OG+aToQRlaH73E0NJ5DI4FXcg24hLNBKAfmuPC1uJBuAH
         yGfu1lcBOqTLqMr9S6RMLzilS4xRvezUVhCs0ve/PcqsF6XWm1u9U6hqLsS4OlBOQ8x8
         ACZ62p2Zch8Ju+LBrHh9ZO/dL6TbqeeygxlHdkxClX8aRnFHvAxjgzHISXZf6vsFfiZT
         Ou8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LzU8Bo5iest5jchhiQ8SOcdIrjdY2O1BrERsQgbTOr0=;
        b=ahPEgTorY7ruEzikJNnMIROYwNuLJjBzRevGY+J+oL1WJNeXV8wssHaEVbdkPCp2Zp
         wk9or4g4EzLIS7TIc9qgiQjd3CvCgOeIHjerd4qtM7dml6NAlZH9P9uj1yQ04a8l4BZs
         gYY7GYSOBebFLkN71mMDqYDMdkhddHtCOYZrhVMpYe0j95DDTT6Tj5g7dAyT+HK3LZaK
         iF2cW+/TzxG4K/ejJhRmjdgrfQQ03/DZLLs/G0USX+mJoJM0e4kc0wfHRB344YSlmjcU
         3xZX/i2jPwy3b0stIB9Yz37chpsAu37HgAyblMpJTBYu+AOqQRPomP1pXYvoRurSgiZE
         gONA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vfwuxtJ7;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v3si4467101pgn.546.2019.02.23.13.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:11:26 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vfwuxtJ7;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4BE992086C;
	Sat, 23 Feb 2019 21:11:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956286;
	bh=NKCQb/lmqZqHb0pIRRcQEnZzTmzMgI0WWkide4Sal/Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=vfwuxtJ7b//Tkn9BXh091Jp2yVdARvsy6HekR7IqYL9d/GyoT8izGdpxJF4AO3T6b
	 MixnexyTsM21T03EZwopsO6tQ9PUPlzAqONDFwpEYSvQ4GeCdk7F3WMlVQ7c/1Bzhi
	 ua+zBzTa41mhP2xFDidSXOOcaIxOf/p1vH/QPdv0=
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
Subject: [PATCH AUTOSEL 4.4 22/26] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Sat, 23 Feb 2019 16:10:43 -0500
Message-Id: <20190223211047.202725-22-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223211047.202725-1-sashal@kernel.org>
References: <20190223211047.202725-1-sashal@kernel.org>
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
index 0addef5f8aa31..153acbf5f83db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1358,7 +1358,8 @@ static struct page *next_active_pageblock(struct page *page)
 int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
-	struct page *end_page = page + nr_pages;
+	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
+	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-- 
2.19.1

