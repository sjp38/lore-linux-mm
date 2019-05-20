Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B02C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:24:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C43721479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:24:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N8pF2wjj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C43721479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5CFD6B0005; Mon, 20 May 2019 17:24:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0E466B0006; Mon, 20 May 2019 17:24:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFC286B0007; Mon, 20 May 2019 17:24:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64A546B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:24:07 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k10so7094919wrx.23
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:24:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=eaw7V5Dbg4CNBGKfurpqorguufLgU2XVBAqZBMsjgmI=;
        b=oMb2L1Yr4B0jIxZ2sKy/snOFKYoDBnxnkM08gLVAEtpEScMbTrxtNpeBsVkXarl7+Z
         LZMH3dRDqbwLhyWM3qkfEBmqBzAVQZgoCS+9BmQP0at0SlQInN5oErxSklAABgNPUFiZ
         6qEL45KTTFEzNAcolqPiMY1nUaQmSvyEbebW17jjobvCU9lamEA06R43W+TJxENeYwOd
         JMAEk2yqt16dfz2oclSA5eN5TD7S3zQqeDsHKkkvZL+PMaxoTJ4VR+a9FfxbNRrsjW+h
         OL+VnOV5ejtrE87gZVR4ihcqsiKWU5Omhgacz6osqDqYWIx+PnaNI35muYEGYLb2QfuT
         UiEg==
X-Gm-Message-State: APjAAAUfy4rwK6mE+MYMZhkBFtSloLw09NINGxX7Gpx+NBHRl+MOHbQn
	duekwzZXiiVD1rADYaBqAcyUXAphE+1ad8TBxg0bJ0hSqTUy6Wbazk6ijRLtXhS3P6tGvCDxBFt
	+R1iOVtRN5JDiJUVoIvFu3hbjQ5CsKqNwGfVTi3uLPvbv+QO985kfrJLuyjJlmD6XtA==
X-Received: by 2002:a5d:6406:: with SMTP id z6mr4250294wru.87.1558387446851;
        Mon, 20 May 2019 14:24:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+XluRh/sm57rmUz0wUq8d/wQHz4MSiBuxGaI2T+iubOqKzNtByA6UlAXFfjSD7wp5nZUe
X-Received: by 2002:a5d:6406:: with SMTP id z6mr4250253wru.87.1558387445707;
        Mon, 20 May 2019 14:24:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558387445; cv=none;
        d=google.com; s=arc-20160816;
        b=FPeM7+08TBIisHvGyHqGKdPbiG1P+vWm5gKv765GL3yCuZEjwf4wRrH90ntQ8XcdiV
         rYCPhXkwHqGIF/tzOL37SuA0fvK7Sa/NgoI1Ufj6hLuvBDgoaLTwekOgoJ9APerCy1SE
         OONCZNgrGER4oNMo9aoVti1KBdsIIsRVnHijQZnynVXSu6ZKrqCBqQdPocEaA/s4pPDl
         VPFCfnX9d8sOwalrGbgiR9LG6nMUPUvm8ndX+j035LUA45+gbOiXLeZXdxlc7SNtwnMZ
         u6m2vSXfMjdssRGF5d87cEeAWPOxdoPJ0QAwhKFqmsnZFu8NCivbZVEceKWHqHgbHCv4
         S9cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to:dkim-signature;
        bh=eaw7V5Dbg4CNBGKfurpqorguufLgU2XVBAqZBMsjgmI=;
        b=K50badlYrVn/jZu7qHHplhnWcHB180WECy8MzkmEYol/hY9SUNvaVpnBtsVCnZn3bw
         3pJpSo2FlDO7D/TwwIzq5sDqPqOqRPFzY5L56f2gNwXFA6Vv2OVchUeI8mnlR7NHvCUm
         asAU1aVjyBfDL+zUn5aNBdD/1DvdwjkJBUp980Op83rohqc83KN5hz8IqcAUeVUEnWHl
         ugXJh58ThjtFJk4GNP2Ht+aSPCa/aDsd9hxeQ+9VszGxhq1JTDtcYWo3qFEPr6c6P8jz
         pPMG8v36U9niXjIPjWXVRs5nZSfKIKFD3dCeLxPkNJScagpn4UlPklWRPYlJuNLzpn1k
         LTqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=N8pF2wjj;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e3si13651862wrw.242.2019.05.20.14.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 14:24:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=N8pF2wjj;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Date:Message-ID:Subject:From:Cc:To:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=eaw7V5Dbg4CNBGKfurpqorguufLgU2XVBAqZBMsjgmI=; b=N8pF2wjjegIQ5BFAHzhQQhYwua
	azynUby+WjWAhF+llhmz66R0WAn00jqTMpUKBZtodVpkIiPZG+g6LGTRL/0fskjl6vGB2b+EMk0oV
	JttfI1V/9U5BtqZX9EPpCQf/QjjJj6TJo5MDAmK3FKAtlMIJk6KKqPCKJEL9XlBiMsQssmXloTZJ5
	fdDaakw1G8LzBzWS93z/s5PGvaUYHiXyJCW16/mUInfnAv+Z97PdC6kl9Hu4PgZmqeZb1vBBlILh2
	kbAeoX2NGaWfIMyuhXRe54ppl2vs4X9WZkd6LFQpoh/GTY5ZejT4qGkEvW3hQTllyyYR1DqcI8Hax
	BgKoZjQA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSplL-0004bZ-2E; Mon, 20 May 2019 21:24:03 +0000
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] mm: fix Documentation/vm/hmm.rst Sphinx warnings
Message-ID: <c5995359-7c82-4e47-c7be-b58a4dda0953@infradead.org>
Date: Mon, 20 May 2019 14:24:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix Sphinx warnings in Documentation/vm/hmm.rst by using "::"
notation and inserting a blank line.  Also add a missing ';'.

Documentation/vm/hmm.rst:292: WARNING: Unexpected indentation.
Documentation/vm/hmm.rst:300: WARNING: Unexpected indentation.

Fixes: 023a019a9b4e ("mm/hmm: add default fault flags to avoid the need to pre-fill pfns arrays")

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 Documentation/vm/hmm.rst |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- lnx-52-rc1.orig/Documentation/vm/hmm.rst
+++ lnx-52-rc1/Documentation/vm/hmm.rst
@@ -288,15 +288,17 @@ For instance if the device flags for dev
     WRITE (1 << 62)
 
 Now let say that device driver wants to fault with at least read a range then
-it does set:
-    range->default_flags = (1 << 63)
+it does set::
+
+    range->default_flags = (1 << 63);
     range->pfn_flags_mask = 0;
 
 and calls hmm_range_fault() as described above. This will fill fault all page
 in the range with at least read permission.
 
 Now let say driver wants to do the same except for one page in the range for
-which its want to have write. Now driver set:
+which its want to have write. Now driver set::
+
     range->default_flags = (1 << 63);
     range->pfn_flags_mask = (1 << 62);
     range->pfns[index_of_write] = (1 << 62);


