Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA98FC3A59B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 10:51:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72F32205C9
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 10:51:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L/TiJYWG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72F32205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C97786B0007; Sat, 17 Aug 2019 06:51:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C21846B000A; Sat, 17 Aug 2019 06:51:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF7A6B000C; Sat, 17 Aug 2019 06:51:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 857FF6B0007
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 06:51:27 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 21C131260
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 10:51:27 +0000 (UTC)
X-FDA: 75831603414.03.stop67_ca1bf86b5a3a
X-HE-Tag: stop67_ca1bf86b5a3a
X-Filterd-Recvd-Size: 4623
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 10:51:26 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id b24so4474004pfp.1
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:51:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=e73g784pEuvRaYkV1Qn8G55TjYtK3ARicu4v3k3AYK8=;
        b=L/TiJYWG28ghyEkJJ1i8Rr0nYi5kkM/z461r7S6FCzbiM7pHaDaBzgwwzbry0aiV3w
         oSVTjm9psNf7L6J9IIcLSeAKSoXVUC/3HGuk+i9ul7pxp4ZckhTMMfiGpRCHTTmhuSI4
         EsbN86FIPqbXsG0zpy35IsWfpnYh3V0cfiphaIHgODHB19qrSJeSZZpXVvb3StqvwFJh
         5hLn3wwiJxuCDGXIjcS6D5mkl8n9qNLnkjzwVlXAEMo0S4XRS1cv4gTazZqqK0P9JtO+
         MhGo9wF47uXF7qVpKMCdr4mcqgGqEXjwqD7k0oX0/YU1B7dxJuRFiO90BTPwZK/JNGLX
         kINA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=e73g784pEuvRaYkV1Qn8G55TjYtK3ARicu4v3k3AYK8=;
        b=lBxA06Ta9kswxgj9GHjG0XN/oT+qkkYyqomISfBSVybLR6vAHCTZ8QxdW5eAl9wl/B
         TN5A/lT5Gvriqq0CBorBT3WZDPnvLof8FxwipPcvVybxnjE56OFMeJivVpDpl0BD/A8Y
         +lQSr2KUtPD9oGcQDp4/rFROjdzVvtVm2qLbaZO1vmZoYaR+mL6uTlo+Az+X4r20Ziwg
         gM14cdGw8dT8FtGI/hTaQWa08QwkA+Uy4XgGfXQRPDVWU1nWn1dKwkLvoi5l6SwPssYo
         BUXHK5Z9JIIRrwlaos1TAo9aScQoDuIKyZZGgMLMp8M8BDr+CEnzOmZ0iTGc37VmSYTc
         WqUA==
X-Gm-Message-State: APjAAAWTSNSWFZeOomCn4NG0LeDZEmgvEIMVCebG+r79dzgDcta3zRhW
	BOIrmkfqFH29oqOdUNk8+mI=
X-Google-Smtp-Source: APXvYqxy7g7+zbKxk+cAbT0qd+YvQjEWcC7SI9W4jBPUYcJHNSQ/ApGRe7qOaI4sww4O4RWdBWwFEg==
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr11346687pji.136.1566039085619;
        Sat, 17 Aug 2019 03:51:25 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:ac8:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id f26sm12910838pfq.38.2019.08.17.03.51.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 17 Aug 2019 03:51:25 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	vbabka@suse.cz,
	osalvador@suse.de,
	pavel.tatashin@microsoft.com,
	mgorman@techsingularity.net,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH] mm/page_alloc: cleanup __alloc_pages_direct_compact()
Date: Sat, 17 Aug 2019 18:51:02 +0800
Message-Id: <20190817105102.11732-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch cleans up the if(page).

No functional change.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/page_alloc.c | 28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..51f056ac09f5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3890,6 +3890,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsign=
ed int order,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
 	struct page *page =3D NULL;
+	struct zone *zone;
 	unsigned long pflags;
 	unsigned int noreclaim_flag;
=20
@@ -3911,23 +3912,26 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsi=
gned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
=20
-	/* Prep a captured page if available */
-	if (page)
+	if (page) {
+		/* Prep a captured page if available */
 		prep_new_page(page, order, gfp_mask, alloc_flags);
-
-	/* Try get a page from the freelist if available */
-	if (!page)
+	} else {
+		/* Try get a page from the freelist if available */
 		page =3D get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
=20
-	if (page) {
-		struct zone *zone =3D page_zone(page);
-
-		zone->compact_blockskip_flush =3D false;
-		compaction_defer_reset(zone, order, true);
-		count_vm_event(COMPACTSUCCESS);
-		return page;
+		if (!page)
+			goto failed;
 	}
=20
+	zone =3D page_zone(page);
+	zone->compact_blockskip_flush =3D false;
+	compaction_defer_reset(zone, order, true);
+
+	count_vm_event(COMPACTSUCCESS);
+
+	return page;
+
+failed:
 	/*
 	 * It's bad if compaction run occurs and fails. The most likely reason
 	 * is that pages exist, but not enough to satisfy watermarks.
--=20
2.21.0


