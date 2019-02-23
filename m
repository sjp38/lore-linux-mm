Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4DDAC4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85B4320861
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:08:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="g2LsDnod"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85B4320861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 318438E0135; Sat, 23 Feb 2019 16:08:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A07C8E009E; Sat, 23 Feb 2019 16:08:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167908E0135; Sat, 23 Feb 2019 16:08:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFF618E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:08:28 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 134so4579483pfx.21
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:08:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B/69q48IzpEQVci5fIhxJN7maI1Yg/iL/VXTR3BJv3k=;
        b=F6aeJi0OqADE0z6Mhox24RWfNrp/8imVakHCS/u2dMoVJiTTmKwYG5T/fGkGBqva5Y
         zxTCgQufH4E1fFxCxDyNYVKWuW+aIb0HfgaZIw56EDQvScZa3bbF1cupMjPkHKf29vFW
         Y0JFiCTbbr8zqmpKEXIImO84G8kOBzq7yEaOGDafM3GLEs56Bf8SmwBPT22TE+4L5ig/
         kl8zrLLnxV8AmIywXVLa+hTqYxdC7qxD1KxXSnIvq/5Ma4/wlBV49qzwa5255cOAC9AM
         nyIl5X/iL58cZsJynZIj9HOZE0mw7snn4sR4nSFFYywNtMdqQ19oiESBD50qb4vRLcQW
         kJ5g==
X-Gm-Message-State: AHQUAubii4De3XDkbl/FqSsIQasc9tmkKKD3nroJiAmRh4KlkPNmkDTz
	fNmeCAcLUMxQnLHT+744XwyKu/TsjmJjZ8bxrnDrOpSHHh9jAveLpwfWHJW76iuPtLjaUis/FLo
	XRRYtQA80mlNC8Dn3MC2359feN5g9wTdJAre/qo44rMxydsNWY3rk91BzNkxfCeNqbw==
X-Received: by 2002:a62:6ec3:: with SMTP id j186mr11412030pfc.89.1550956108363;
        Sat, 23 Feb 2019 13:08:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZqzPw09jXxnqiRfPCqkcpS+PQRsdKrovxJG4poJco1Tag7AQLwPKonLGYc5r0Qag1DTOxr
X-Received: by 2002:a62:6ec3:: with SMTP id j186mr11411964pfc.89.1550956107476;
        Sat, 23 Feb 2019 13:08:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956107; cv=none;
        d=google.com; s=arc-20160816;
        b=wrU+Wk3dKrYcJQf4bNZblGFKIPpgTydcCs7/wQwgEKo/Y3SGtRwoi3uh6KxCGCDwzu
         lwhY1p9rptV3oPCm7bP7aAh7ZcLnNok+nxLbJTsV0k/NDlzNaoYcxFqHvkr7zFOqUTSS
         BUChT+rCjewWuoE6ugvdNiqIibWI13nSctx3TEj1cQrrN0GFTaSdlPvbp0QmvGaPbO81
         J+xn43ZNV9jWf8ZczpAsF+SVRzi7XDuDCsrAOlwJXVWckNlgGn+lkz2wq9rCpGZHIEOL
         45YsnRXCheVPFkxE4G2z5O8Tq+pSvphdw9lx/WfIlxCoox8XZ9Q2yye0aoXk5qDLqY4W
         kWow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=B/69q48IzpEQVci5fIhxJN7maI1Yg/iL/VXTR3BJv3k=;
        b=qtBmWzTPjgewRKymfugvN54Ta2kAEcFFjFOaS6UvvdI/k5JNO7zEP1Wq9HGYWHzd8G
         0MFodCxQWP/hdxHlqtYYRwj+tMoG3GBWVCF1j3MofSuvyR1JNz9kPL9XoEigzuybsYi1
         pgBGx18uKWzVC6wQcdZEDs0W2nlD3LU/mjpT3EvVnd8rzPtDEPuT65xjjJFcZw3aCq7T
         AP4jQLrduckYJbtjhDb5/Sk2IS2SxjnH4IXCzvoRqUy1v40QWSKALYbfWUCCghNOXUMI
         uj1XmDS887Ehn6Q86vY+xXFh6d0vuk+bbfyAUc8ZkrQNor9Yhu0f4hL+soTR0WlmbeSj
         UfBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=g2LsDnod;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 68si4506953pga.497.2019.02.23.13.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:08:27 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=g2LsDnod;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0405D20861;
	Sat, 23 Feb 2019 21:08:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956107;
	bh=mpb9MU/ezaiRyvGhc3PViVUm6a8DFRWtxx5dhnJKjx4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=g2LsDnodEXEfpwqgtM9Wj0hYDH19phf1h3ANe5Mo1Hl07+otMJyk1nKJtnlaTZ1t9
	 9+KYz7BL7oknaz5o0CZTU6jLia+Z8+2YS5tw0yNtYbN1+AC1cqZ+N48//sligfbZtB
	 M3DWCGaC1QQg6Zt7C3OQuktha4ix7Qt3rV6zYWg4=
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
Subject: [PATCH AUTOSEL 4.19 60/65] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Sat, 23 Feb 2019 16:06:35 -0500
Message-Id: <20190223210640.200911-60-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210640.200911-1-sashal@kernel.org>
References: <20190223210640.200911-1-sashal@kernel.org>
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
index c6119ad3561ea..34cde04f346d9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1258,7 +1258,8 @@ static bool is_pageblock_removable_nolock(struct page *page)
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

