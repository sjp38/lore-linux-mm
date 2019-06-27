Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73CD7C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D38720656
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IusLSOBj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D38720656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A95406B0007; Thu, 27 Jun 2019 07:54:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A459B8E0003; Thu, 27 Jun 2019 07:54:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BFE68E0002; Thu, 27 Jun 2019 07:54:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56CBA6B0007
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:54:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so1323552plo.6
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:54:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AAp8d968Yh2opGUVOFegnzF6eMOu3mT7GyxCSQBbrz4=;
        b=HsRhGZ097V2Op8bzO5sm2o8FrC/PIs9HRzxkLTdLenDSGa7Jtf7RjOLgmrXiOjFxpj
         3IF30+3qkZDiWP2ecxsDEXZ2t61K353JVmb8ChOW8hPJMg+UTe4lYLb0TmwJrBOCPlnH
         TCzx0r7AW1Ecieut7bwlWe/TwYn7fOnmbicC9EigQEomGwt5kbYhmt3wqI66P9GqAUQq
         GYmz5rkFRkjioVtqIp202ej8ls0oKjxPIGL/3WUDBaAAkqMD82QlbOgS4uzFwDVxOIvH
         5oMONZgNHHlSijPpFDLFaqf8a7bG/7CukPm4fMeo8gqwdkHuschoXo27rEwZxvHEuAeY
         1UDQ==
X-Gm-Message-State: APjAAAWxyoNEnXjFSebcOUUUAKSlKtbc61Z+UTBv3v/Io/KnUcZKLUgK
	fVUTEh9BsQcCbI97XQsJtzje4qxSh5b+pz9oBUQU7phRu/meEt7ihyIh8yxLcEohBlfIjDxEVNM
	Q3vUUkP4TxHyfA0nSk5oERZ+2pH21vLG/FS+MsquhtsIEj/JWLDgFvi3b+gSz7iI=
X-Received: by 2002:a17:902:a9ca:: with SMTP id b10mr265773plr.69.1561636466915;
        Thu, 27 Jun 2019 04:54:26 -0700 (PDT)
X-Received: by 2002:a17:902:a9ca:: with SMTP id b10mr265724plr.69.1561636466196;
        Thu, 27 Jun 2019 04:54:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561636466; cv=none;
        d=google.com; s=arc-20160816;
        b=mBVUAo7+M4NTQjUe7JVjhYsmd6fxtr6BauVsME6yZr1p2E43QJfDbSy5T92o6bmjTy
         ouk+H2ZxTed4xF7ytv/c7XxMssHbadf7ZJHVe7D45/7XjZ7542fMwCgWTQ9qvFYTQzxH
         B3fOJ4IlUb0D2CC1Jvn6m+bb5EVq/IYoYfHHgJNRrsk8rwEOmbuCbzctV03V2B3O5tet
         YoP6xJdJuv/hIKfexad0WyQdChzlT0OhStSJqsVGL02gf+iucGlNmeOkmZ3bhMZi5v/z
         QRnLRac1v3WD9lePX9/i8MxpNblAsl6LRGEEVgX8tKYoWzzYyda4idLilovJSuri7BYJ
         66Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=AAp8d968Yh2opGUVOFegnzF6eMOu3mT7GyxCSQBbrz4=;
        b=fAMXTLbhBAPwuwMmQmdN1pjmcF58a65jWGCbpOeB0D8JLmWgMvZrgam190yt6CCjDb
         u3pK8ddPZkBJGuUPQyh0DqgKIvrRCCshN2QBmZ5iU/IIvOL/0H1hD472fPiDkNCnY4dN
         Xe/ME+EJWQO/UxgAVTMyiQBVnwB6iUCBPb7CzHD1K9948gKZX3EC1gcVWev/s9V7qlMN
         rodF9n8yvxR+l7N2sXqAW0ltl96mng2OpdM9Xif25vPbkzljWjyJkaprfF6JpdiZIb/A
         7cZ04Q9butylDReJLhSghjJnqVw0k7jgNO9JYOLxQ4NmyRus1xBCwYkQSg5iRV3vsiVC
         Y6wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IusLSOBj;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f194sor1041732pfa.8.2019.06.27.04.54.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 04:54:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IusLSOBj;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AAp8d968Yh2opGUVOFegnzF6eMOu3mT7GyxCSQBbrz4=;
        b=IusLSOBjKyjzEsTIjCyYaX7iDxTc+jt9jznyuZqnSu292hsSCly7AXcCPkLqGadrsU
         GS3+VBsW8saL2SZYTRKOIxeQ4qrKDrv/fiq8yO1AsrJVbWUPIQa18kwtFnCB6EmUDQgY
         zmFLUSMSOckUpxgrm8gQPnSy/5YIi0WHywEMXVeEd1M2sABbbe81pzPqtIg8yXZhe15d
         VSCTBlwiaMVgs+x0+j5D2+nmM5ulbkKn9ovG7BEb6bOsx8UVMyJ5E4LoQaQ5FWBAiiTp
         mOtBV7bnx9ZmbLyR2+r9g1qY63mV6QqOqAD6BZmkxF9j2IcLNTQNhQupulksZ+bvJWl1
         jO6A==
X-Google-Smtp-Source: APXvYqw+UmMVOCkMwFhSUPGnw/i5c2zgEVNDeOFbpvqoW2kE2ETfKhNvJF6jlv44hoNP2zJ6SNMOdg==
X-Received: by 2002:a63:4553:: with SMTP id u19mr3404760pgk.420.1561636465689;
        Thu, 27 Jun 2019 04:54:25 -0700 (PDT)
Received: from bbox-1.seo.corp.google.com ([2401:fa00:d:0:d988:f0f2:984f:445b])
        by smtp.gmail.com with ESMTPSA id x14sm3241419pfq.158.2019.06.27.04.54.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 04:54:24 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 2/5] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Thu, 27 Jun 2019 20:54:02 +0900
Message-Id: <20190627115405.255259-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190627115405.255259-1-minchan@kernel.org>
References: <20190627115405.255259-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
as default. It is for preventing to reclaim dirty pages when CMA try to
migrate pages. Strictly speaking, we don't need it because CMA didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Moreover, it has a problem to prevent anonymous pages's swap out even
though force_reclaim = true in shrink_page_list on upcoming patch.
So this patch makes references's default value to PAGEREF_RECLAIM and
rename force_reclaim with ignore_references to make it more clear.

This is a preparatory work for next patch.

* RFCv1
 * use ignore_referecnes as parameter name - hannes

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9e3292ee5c7c..49e9ee4d771d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1117,7 +1117,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1131,7 +1131,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1262,7 +1262,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.410.gd8fdbe21b5-goog

