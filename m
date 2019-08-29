Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 319FAC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 03:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB1B723403
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 03:52:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="kQTlD7Q2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB1B723403
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 797596B0003; Wed, 28 Aug 2019 23:52:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 720336B000C; Wed, 28 Aug 2019 23:52:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 635C76B000D; Wed, 28 Aug 2019 23:52:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACF26B0003
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 23:52:04 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CCBAF180AD7C1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:52:03 +0000 (UTC)
X-FDA: 75874092126.17.list43_691f38eddb61e
X-HE-Tag: list43_691f38eddb61e
X-Filterd-Recvd-Size: 3439
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com [66.55.73.32])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:52:02 +0000 (UTC)
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id CE9F02DC009A;
	Wed, 28 Aug 2019 23:52:00 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1567050721;
	bh=HPG14nExqVPJ4V/n3bFbBw+g46PVLmmj5APpE7/lKv4=;
	h=From:To:Cc:Subject:Date:From;
	b=kQTlD7Q2CwsLpIAZBeIdnTDzDkyyTPD3/t4onT0b6wizxqd6CU+/B6GnFwc77UXLW
	 zQufTKy0xiD0dpWg0Ej/sLzg0w8u7v98Yw8KBWqEkbsecWc5nsA1tnXoPVBbeYduFC
	 KSpWI6CDvTAmQORs7q7tQ1IF9Xw9exwBVH2fx03tRPKwsq6cKdnwykxAUmyuMh6ROa
	 p3rVk3OrUkYlE07dOCRzmjerCf39jVYotQ0rVLnkjR2cB4TLtbqx6Ddhy7/jJmNwuw
	 Y3MKalyHCpTOSTlj8vN3kV1niNWswuEupRqDZir3LfL2sjEdqOnlrO/qRn4IWC66a5
	 NpEwzF3yaIf6cUeGGGZQzkoEdhCcmFMtOuzR+RIQDBAYQXlgo9C5friS3LsTPeydiE
	 EdanqsVwmduOVy2VPEiXni6TvDCOzTFIMy8g2BpGMxH2+/rnEmMFTo5YO+JHsla89V
	 H0yrSM4z59/+MclAR0fkDkBixbHm7I9b/oAz4yxtePbe8/IVfCV3sP2OK7LhvduRJo
	 ZJ4S1KwXGj2tcDHNtGFF49UzDhZiebtyQUJ0MdbdGK0dQF0dm62zZFZBDKzU1HCbQE
	 UekCp1vX9DXfXyoASEI6iz7QAQi/4eNkb7kfL7qCD/IzBPmUzizlrkvy/ehr/zU56N
	 pcJZXyksl1oTi/zaJudzhOIc=
Received: from ibmlaptop.local (ibmlaptop.lan [10.0.1.179])
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x7T3ppAq061198
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 29 Aug 2019 13:51:54 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
From: "Alastair D'Silva" <alastair@d-silva.org>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>,
        Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Logan Gunthorpe <logang@deltatee.com>, Baoquan He <bhe@redhat.com>,
        Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] mm: Remove NULL check in clear_hwpoisoned_pages()
Date: Thu, 29 Aug 2019 13:51:50 +1000
Message-Id: <20190829035151.20975-1-alastair@d-silva.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Thu, 29 Aug 2019 13:51:56 +1000 (AEST)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is no possibility for memmap to be NULL in the current
codebase.

This check was added in commit 95a4774d055c ("memory-hotplug:
update mce_bad_pages when removing the memory")
where memmap was originally inited to NULL, and only conditionally
given a value.

The code that could have passed a NULL has been removed, so there
is no longer a possibility that memmap can be NULL.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 mm/sparse.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 78979c142b7d..9f7e3682cdcb 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -754,9 +754,6 @@ static void clear_hwpoisoned_pages(struct page *memma=
p, int nr_pages)
 {
 	int i;
=20
-	if (!memmap)
-		return;
-
 	/*
 	 * A further optimization is to have per section refcounted
 	 * num_poisoned_pages.  But that would need more space per memmap, so
--=20
2.21.0


