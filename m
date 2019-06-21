Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F19C5C4646B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 11:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6B6B2083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 11:44:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eNtMHae5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6B6B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31CF16B0005; Fri, 21 Jun 2019 07:44:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A72E8E0002; Fri, 21 Jun 2019 07:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BD778E0001; Fri, 21 Jun 2019 07:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5EB26B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:44:08 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id v125so908411wme.5
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 04:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=671B8ITw4iRBQJ3GVRyh3fkF3c8OsHI/COzEcd1834M=;
        b=Y+h6g39C0Z8y8E+lSBd0d1D9lbYVLzcWJ4aaRvqYhp4bzzjWL6Z12A0CVUmvJBzuWW
         rCj9XCTYqKGUMFNwba02z4HY7ozrHMwOkmLTGTqPJsva//ke1XMvbIdmNFW6qprrjP/N
         XHiCR91M/cAOYL1dKvMOHni2kCWaaXEFqLOklId/PfibyGje1TLMfRFh+X6MfDT4UwXE
         oJLG/JtkIhsW/s2ZM/2lF7g4KI6z5EjUNBL5r29G2S+cFXJZueiPlbZERxTMvumnBOdZ
         f76m9X/tfktRa7zLLf6U2z2JgMxMXJokD9Pz4F7J/zLCEQkldYl2v83dD75T8FN7qFWL
         5U0g==
X-Gm-Message-State: APjAAAWoyIgr+hFBLm/XxrKGTrokPIADiU+Nv3tCok+z0YMZzbGohZG8
	w50pkSjBS1/nFilGg1IpIcsIJXPZLz7GlSBpydPR9fDPu5fl9X8zQly8j6rqDPoEUXOcTxa5cSF
	KDJKd5Zr2TyMju7HRLVP6hNW5r6i5kkPZJOwv4IZyXCd7LI0qY3zseNb5KAcuun/zgA==
X-Received: by 2002:a05:600c:224d:: with SMTP id a13mr3803864wmm.62.1561117448192;
        Fri, 21 Jun 2019 04:44:08 -0700 (PDT)
X-Received: by 2002:a05:600c:224d:: with SMTP id a13mr3803819wmm.62.1561117447168;
        Fri, 21 Jun 2019 04:44:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561117447; cv=none;
        d=google.com; s=arc-20160816;
        b=JI0sU3WO5YgBcOr7AzoEV0FNJvGx4FoIRd95+cmwIF240DvB3+Uvtvy+32j568YRxT
         yhO9WWujwhB17PCqZPSMa6W+KGGjglyfQp5DfiSye+kTO2YC3lTV3h4m+Nomsh5KwiqQ
         r9Eh/XRUK0uEkVorA2cmv5huy10YivvsdH1Cn0InFq/t/MJwgnqEZoN/W+1PiQvw2BtD
         YRZpzomRXROgTsavvLPDSgs1XWeAbGgOGXunaW9h3Ah13Uwh7fcP1LISnJ2drRJcJrZd
         qDYy4GLLnWXi3ukDbODt+FeCcT8GVrYqNYH1KbmSwldklDhP9OEIeXh0BhgHiXtKm1ol
         tn0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=671B8ITw4iRBQJ3GVRyh3fkF3c8OsHI/COzEcd1834M=;
        b=BnPXE/GZJSCTNRcSsjWzc3s60UCPVZxHp0GtjMWYAmGFh+5QF8ah3F4qSH6p32I87m
         7/A1lWLfknUDLiq0qnQj2D4mgL1kTWubkPJ8SGRGBtRrnhJhUKv3xYu8JNXiRPFDiIkK
         Ph++BgTPLzvNxkbk9P17cvJNNRZQthpk9TKvZTwbZuzGQaFX3s6OcfUS09UbkpELuVyC
         y0sFgPre2lRhbMmpG/PHJF2RQPPJY3MEY3mJPcFoisxX8TuU/CcC6PysMfoXCxSepPZm
         jJcb+FUg1OG+gZ/AkkIOfXYvszCQuvA8VGrRC7K9BrywSorBF+5sAdpR/k5JlICm8tMj
         Rj/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eNtMHae5;
       spf=pass (google.com: domain of alan.christopher.jenkins@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alan.christopher.jenkins@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o62sor1381304wma.17.2019.06.21.04.44.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 04:44:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of alan.christopher.jenkins@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eNtMHae5;
       spf=pass (google.com: domain of alan.christopher.jenkins@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alan.christopher.jenkins@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=671B8ITw4iRBQJ3GVRyh3fkF3c8OsHI/COzEcd1834M=;
        b=eNtMHae59YB07kaBK2IyGYRtNhXpOIn76XcLvsWX8VXoI+RbfGrhSY+RWVkZkPHSSM
         Eu1AiEN2RJGwgDZ4nSocPVdPN1JVYHhwL1Tisste7lSrGNbk1cOinEo3W9C/HidX9eoz
         Nus+QLFisaKhv86/QJ9U8DxYJ5fFa3sMRYZZTMf/jJPMe1pYkcDhGCSLt7MMFuv0T//u
         Ku4hG5r4nLoPEWdvddObDmdgahkN2hrb8wL/5mXyn7jQLoQUZJYmvxr3GQX07+wR0UF9
         y0UiOIesN6VH/z4/nBy7aOHbLH5RrVyqgNu1+nnz/XRuEDRAmz1wPlC76SUbevC5ggCk
         PDxA==
X-Google-Smtp-Source: APXvYqwMO1kthRI1MdROhaylSw1sgGK/5sYomAtT784ZV+TKYvX7heUFUkZWJRfM37dLdrva1oW1eA==
X-Received: by 2002:a7b:cd04:: with SMTP id f4mr4147489wmj.64.1561117446857;
        Fri, 21 Jun 2019 04:44:06 -0700 (PDT)
Received: from alan-laptop.carrier.duckdns.org (host-89-243-246-11.as13285.net. [89.243.246.11])
        by smtp.gmail.com with ESMTPSA id o2sm1698861wrq.56.2019.06.21.04.44.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 04:44:06 -0700 (PDT)
From: Alan Jenkins <alan.christopher.jenkins@gmail.com>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Alan Jenkins <alan.christopher.jenkins@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH] mm: fix setting the high and low watermarks
Date: Fri, 21 Jun 2019 12:43:25 +0100
Message-Id: <20190621114325.711-1-alan.christopher.jenkins@gmail.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When setting the low and high watermarks we use min_wmark_pages(zone).
I guess this is to reduce the line length.  But we forgot that this macro
includes zone->watermark_boost.  We need to reset zone->watermark_boost
first.  Otherwise the watermarks will be set inconsistently.

E.g. this could cause inconsistent values if the watermarks have been
boosted, and then you change a sysctl which triggers
__setup_per_zone_wmarks().

I strongly suspect this explains why I have seen slightly high watermarks.
Suspicious-looking zoneinfo below - notice high-low != low-min.

Node 0, zone   Normal
  pages free     74597
        min      9582
        low      34505
        high     36900

https://unix.stackexchange.com/questions/525674/my-low-and-high-watermarks-seem-higher-than-predicted-by-documentation-sysctl-vm/525687

Signed-off-by: Alan Jenkins <alan.christopher.jenkins@gmail.com>
Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external
                      fragmentation event occurs")
Cc: stable@vger.kernel.org
---

Tested by compiler :-).

Ideally the commit message would be clear about what happens the
*first* time __setup_per_zone_watermarks() is called.  I guess that
zone->watermark_boost is *usually* zero, or we would have noticed
some wild problems :-).  However I am not familiar with how the zone
structures are allocated & initialized.  Maybe there is a case where
zone->watermark_boost could contain an arbitrary unitialized value
at this point.  Can we rule that out?

 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c02cff1ed56e..db9758cda6f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7606,9 +7606,9 @@ static void __setup_per_zone_wmarks(void)
 			    mult_frac(zone_managed_pages(zone),
 				      watermark_scale_factor, 10000));
 
+		zone->watermark_boost = 0;
 		zone->_watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->_watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
-		zone->watermark_boost = 0;
 
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
-- 
2.20.1

