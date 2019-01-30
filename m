Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55E1DC282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DC6E2184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DC6E2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89C68E0003; Wed, 30 Jan 2019 04:12:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A26C48E0001; Wed, 30 Jan 2019 04:12:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C5D18E0003; Wed, 30 Jan 2019 04:12:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 389BA8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:12:30 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id d11so8858762wrq.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:12:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jqcIWXioD2gkdPhR+3oNYtx3Ld3P23Y8DhdWLsl2n/o=;
        b=ZsauuH/6Fbjy2UzqTLwqPtPQYDIYrssTQMp2IjbhVKhDXnaRjW/qPaDp2s3P2vPoU3
         84r6aefkFna2ZhNNmK4dtOp1UOmk6gc5T0ezU2gsyipHM+9eR9XyyJ2I9fMSyD9Ff/qZ
         RmwoXT/D3Lh4KQjut4tWBgs9in4tbXdR/o/uO5izwQTvt6qi7j2OUE2AYpjr8Xw5TvhH
         ow/SgWkbNDA43FjaydJ+y9LQbi+F3LHLrmfXz8IZv43cbLxv4nEMXCh4Q0QT2Z56hQKK
         fN7K0gYZFSzgHmi+P35zEyCapRKmRjEDlPuq0I/QARdXz/nB2069EUTsGITTtpn+FVEV
         l0Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZStx9HNXgjOqqeWyLxJXcYYbNF2h3lpuLBhxlKEpDHlAegyj/C
	NWEaOnk/lnofFjp9XWh+MqkH8cGhzQSYkpZ+bnUucxHA0sPmW5a3Yb/4FcUOhBn3b1SXdVyDojh
	mSxTo6fQ8YGuLrehwRam/nGgRFsBst3Mtf29Guknri26OAsHBQG3TfsHuVVD8dciS+6TBmKmzN6
	YyOiUC96F4gByV2ZWkiL9tqU7xCNHJ7NKrtPXg5PKXDbaq7L3gp8RUbyzhiwJVZ5G71TLPu3jNZ
	5z6qkRAP7jufYkNRfigzuC7JlVIOQXbaL4ehtKvB2AEMzwedeDH6GmAud40TiGBvlE9xCRbxyn/
	OZD0pjerpqwBkivSCextEXCt3srPiU8l4OL9inj92XX7h0wyv9eS4Q0vnzy3+NyYZqSKpD7RGg=
	=
X-Received: by 2002:a1c:23cc:: with SMTP id j195mr13316066wmj.124.1548839549710;
        Wed, 30 Jan 2019 01:12:29 -0800 (PST)
X-Received: by 2002:a1c:23cc:: with SMTP id j195mr13316010wmj.124.1548839548724;
        Wed, 30 Jan 2019 01:12:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548839548; cv=none;
        d=google.com; s=arc-20160816;
        b=g7zOT1nRi2oti0I6p4IuEXUTBrgo/eC665Q5WmkAqT7ieSzCLF4KpUodmfZJ/86a72
         D4H1y6ORpSdf+AlNWQX+e2eLA3kjx4qljAljXq4058GYEHwV42plCdPTwAevWJgozUmn
         XFcaLu0IbxEz+ljPS9TTxXibBJdIuTQApPtPxPGwGhQxxmgHKJ2/EikkKK6VpR7dbXfC
         /311J6HkuZZGar/DBpEGCeqrrRjHDl0Qx8MYK1c/NPuXjbfsIQEiPPnYpqkS6w47qLeZ
         Q40L+BsU0eTYgLgbrFwitoJDmikVySUcHjLiZHykleoJD0aLoGk1uddmncaLaSmtbzow
         my1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jqcIWXioD2gkdPhR+3oNYtx3Ld3P23Y8DhdWLsl2n/o=;
        b=FCwL8ZWis0nVMxXi9bxZjmUpT0h8sUqTui12Sp6OwaQA7ieF2AS8fWz8D1DqhwQ6tj
         LybMueOIVTOWLS9UJ0XoGpqeA7HhApEno585wTymQaPE/pSHw88VmAPOiMweKwvMHQNW
         teSxP09oerZUVsjWTUZo22kW4RWkSuyFFPaUjp7IJzIT8TtFVWXY8RXzjJHLNh3jZkgI
         VkjOeUZtMLP4OtKN7Dsta0F4pHNv8AZAY4ZGF6iqt/dN407NuLXwUH9oUVdeeJhnwFHi
         LtjReto4uIJdLC0JpqsppdDY9qf7Wn1LR/kVMIvR+iC0idtM3csf/MEReyBvy3pasVqP
         cPWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z13sor630353wrl.43.2019.01.30.01.12.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 01:12:28 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN4OLx4B36rgVZODDcO0K8ixVFRBva3FhUwiy8i7CxdLOfPVVkqSieNV7/xg/er1aWb+g0RmCA==
X-Received: by 2002:adf:e7d0:: with SMTP id e16mr30650251wrn.142.1548839548346;
        Wed, 30 Jan 2019 01:12:28 -0800 (PST)
Received: from tiehlicka.suse.cz (ip-37-188-142-190.eurotel.cz. [37.188.142.190])
        by smtp.gmail.com with ESMTPSA id l19sm1491875wme.21.2019.01.30.01.12.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 01:12:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com,
	gerald.schaefer@de.ibm.com,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 1/2] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Wed, 30 Jan 2019 10:12:16 +0100
Message-Id: <20190130091217.24467-2-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130091217.24467-1-mhocko@kernel.org>
References: <20190130091217.24467-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

Mikhail has reported the following VM_BUG_ON triggered when reading
sysfs removable state of a memory block:
 page:000003d08300c000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
  [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
  [<00000000003e4194>] seq_read+0x204/0x480
  [<00000000003b53ea>] __vfs_read+0x32/0x178
  [<00000000003b55b2>] vfs_read+0x82/0x138
  [<00000000003b5be2>] ksys_read+0x5a/0xb0
  [<0000000000b86ba0>] system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
  [<000000000038596c>] is_mem_section_removable+0xb4/0x190
 Kernel panic - not syncing: Fatal exception: panic_on_oops

The reason is that the memory block spans the zone boundary and we are
stumbling over an unitialized struct page. Fix this by enforcing zone
range in is_mem_section_removable so that we never run away from a
zone.

Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..07872789d778 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1233,7 +1233,8 @@ static bool is_pageblock_removable_nolock(struct page *page)
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
-	struct page *end_page = page + nr_pages;
+	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
+	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-- 
2.20.1

