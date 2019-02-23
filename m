Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71122C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FC6620861
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:11:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="u4Yz+TIX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FC6620861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEEEB8E0153; Sat, 23 Feb 2019 16:11:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC5148E009E; Sat, 23 Feb 2019 16:11:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A66068E0153; Sat, 23 Feb 2019 16:11:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64B2F8E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:11:30 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b10so4247855pla.14
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:11:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HWUHNRpuCX/CZFtyx2eY0jQ9GggC5AoKy26LvxaQuS0=;
        b=sk1LtvPLktVProe3jlSO8wdPaBDG9nDtQxJfYWz6r0QET1NiOUe70Ujp4boOjikn/p
         ctyjRY43N4SqfNF8QBqffY/PXue6zGLvf7e7TmloQpQgKZgbKVWCj/yy87OwQ4iV7Pqp
         wnFj9ppGr2LQ2eemEqzyKy/yTFPvwylwuTdA7EZZ2Qpki50iWAOyEYyqiElD5/GN6Vzn
         1xJ+HwwQ+a8D1g7kBxBFdrVKdffAKpyqpAMUxZAZSoW4kDe2IU98NbfISF6OFMm+1TJU
         ADz0htOj+sLIoPwEqxlg+YS3K5yQGAjpE30Efwh7RHQdSK47nLsYh2VxpfZIpt2xqxyd
         0XAQ==
X-Gm-Message-State: AHQUAuZGHIMeBQur4k3q9njRJY7nWePGbo+56J/whxGlL02Zt2p17o+u
	c2IVm4t+hCkdABnDj/Zw0uTb5SxHfvajwYNqgJ1lsgHq8EHCH/lMTIgRckX3AyhzkvBiey8ZMaQ
	tExQ17vtby+ocRmEKHESiAuwq21BToUBBf5ZbjCxdWhvwxqYN4PyTRbI+osVphTAzbA==
X-Received: by 2002:a63:d64:: with SMTP id 36mr10113746pgn.360.1550956290075;
        Sat, 23 Feb 2019 13:11:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZl3gppbHvIv9T+8TB0nz4PxpTJANNUXvpQVAX+ga8LVGOAhuhO5UwEA+NtiBFo5FDlaVZJ
X-Received: by 2002:a63:d64:: with SMTP id 36mr10113714pgn.360.1550956289472;
        Sat, 23 Feb 2019 13:11:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956289; cv=none;
        d=google.com; s=arc-20160816;
        b=WUDlhF0J9pFlQXSWL13hfdV/VWoqURqwH46p+0jvdR1HabY8sXhEXzReciNxa5E/0q
         QWcfHksi90suzpPRbbp4kKDOLMaz6maKJHt2+8i20rcuRTsj8zpai+MElM2sVRXKJfQC
         pjNKtlGV18ljWFT0j771bx5MiZogrZrMVhYRb6KTa4Inu8A4F7MUGr9MY+Gz4qf5bDiw
         73P+04ZA6EvqfFbwpZg63Oh1DXSH8I3qs7RtlZn05T9rONO6V8dFEjdzADWtzQBXxm7a
         crDhWSLMujKeqZ/60aDeggYd+C09cT51OUTaipmCOjo7mDXGh9Y8/iZyeBSWWzcXeGuK
         SAqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=HWUHNRpuCX/CZFtyx2eY0jQ9GggC5AoKy26LvxaQuS0=;
        b=thMM15pRoPQG8Yw5NUgR3Zy50p0tWSsPuHhH+On/1aA/V5lYPT7BiJHlTXliRrRrza
         Vo632gkiyjWdM5FpOsnXOvRFFuibbG+VPnUjL/9eOa3lRTKbZB0/AsH4gFXWlrs1ilZs
         CTZkZUi2S1Wjr8iiVEKbaTrt/6eiv2slFZo4CdjWHR16Gw+tG6ijDqILkKTcPoCMBG/R
         Fl6YsPKhzR1yH8dK3cDURkimfBtt6dWhMQMjnqMdzF3rrpQUdENAlDQzzZmQ3RkrdlXr
         JEpDuRxX/Lc1jVCzITyrPUx7fM+Qfr97BsEbSg1LRfO4kmJ5e7ypgXlzcMYyBLaE72zQ
         BF2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u4Yz+TIX;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i17si4573788pgk.233.2019.02.23.13.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:11:29 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u4Yz+TIX;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CC48520861;
	Sat, 23 Feb 2019 21:11:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956289;
	bh=H288oKZ7xm1LNXoh5JN36UfOyP8XY+Z8q8XgKvZYOTY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=u4Yz+TIX1fDftVHsdGT7QqA+PNpqq7ZW1UEJShWAfn0WLs7HHcdEXkQt6OrXEVBj+
	 qT+C/Wx2/X3E31++SOxQX9rY53FJUUv4qsTzBQupkfEgkvVd5ypD/gkx80S3APPM7T
	 ZOEyntEj4CiyYkvRh1dBVYmEqu+fg+SZzneP+QzU=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.4 23/26] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Sat, 23 Feb 2019 16:10:44 -0500
Message-Id: <20190223211047.202725-23-sashal@kernel.org>
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

From: Mikhail Zaslonko <zaslonko@linux.ibm.com>

[ Upstream commit 24feb47c5fa5b825efb0151f28906dfdad027e61 ]

If memory end is not aligned with the sparse memory section boundary,
the mapping of such a section is only partly initialized.  This may lead
to VM_BUG_ON due to uninitialized struct pages access from
test_pages_in_a_zone() function triggered by memory_hotplug sysfs
handlers.

Here are the the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
   test_pages_in_a_zone+0xde/0x160
   show_valid_zones+0x5c/0x190
   dev_attr_show+0x34/0x70
   sysfs_kf_seq_show+0xc8/0x148
   seq_read+0x204/0x480
   __vfs_read+0x32/0x178
   vfs_read+0x82/0x138
   ksys_read+0x5a/0xb0
   system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
   test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

Fix this by checking whether the pfn to check is within the zone.

[mhocko@suse.com: separated this change from http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Link: http://lkml.kernel.org/r/20190128144506.15603-3-mhocko@kernel.org

[mhocko@suse.com: separated this change from
http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 153acbf5f83db..804cbfe9132dd 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1399,6 +1399,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 				i++;
 			if (i == MAX_ORDER_NR_PAGES)
 				continue;
+			/* Check if we got outside of the zone */
+			if (zone && !zone_spans_pfn(zone, pfn + i))
+				return 0;
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
-- 
2.19.1

