Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D6F4C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 10:38:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11E272075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 10:38:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UdrlvXS2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11E272075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76AC36B0003; Mon, 22 Apr 2019 06:38:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7198F6B0006; Mon, 22 Apr 2019 06:38:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 594C26B0007; Mon, 22 Apr 2019 06:38:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F39A6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 06:38:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so7430759pfn.13
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 03:38:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=8ShUaFNcZ5bsBda1zqagRP6x7qsp4WEK4DhvDe+5Rtw=;
        b=oJWQ/wYccec0xSRL9I0jQGRMWmU3JEvI8ql1Yz/XLhPFTCCxRZccRZsQyxKJAu1f0r
         6v/5cdqqx++TRYYwEfjXZTsC84975PmrCdN006PcBgFN3z9LJ74rPZ31pJol+zrsOcJP
         Hix50lyRCzcumyfMAWNhaLvR/0oVyTRxiBL8sYUcmzXzNHDzcpDRKYQQbMT8SenE3kUM
         Oc52cIY7qGpxWqDv6+nA22oJ3fEuGWZp7Xi7MpA4c8Aat45A4ugZ6cEunfRbN5P6Cnff
         rl92aM7ltHFxgLbTATZHAbm+C8MPXgM31L6CxfbaClLQ9HFPnwl6yL+CWZZFuJvHRFKG
         RFJg==
X-Gm-Message-State: APjAAAV3ycF/MSFqS/9l35GkhSSW9DeZmMGWjSDhUSVlzN7zniC4T8tD
	XY1dcKzJyJBZKFr48p0IedB15Xj6QcGqNlVgqR7YWq3gedtGU3tlQNkcDYm3WvDNxGtofenr6gY
	Pbeu3jl0Shb6daRHzLOTJepqkfOV5MbxPaWXMyJdMRm8DS4H/CFWolRDfwhA60iSSbw==
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr18004293pgr.72.1555929531656;
        Mon, 22 Apr 2019 03:38:51 -0700 (PDT)
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr18004225pgr.72.1555929530459;
        Mon, 22 Apr 2019 03:38:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555929530; cv=none;
        d=google.com; s=arc-20160816;
        b=gaVn7Nh6FssJhJEcFIIYsmNujI8Kt/Cz75SXHQT4/hhPycRoooT4jNJk/Be0nFdGHV
         CRlReE/9RuCbpAqIK/XV/y4+Tq6hvT5xzzH5Zouz0pv2XzbHk6gPofJGWLVdqDMOAlZb
         kLNwg7epIuC0eNdjlRWZFFXRdrneCuMkEgTxVNo+po3F5kkVtJVysrdQuslUPFCyNIbf
         l0XbE4HZZEkC+INBR/g1xvnT6U/CoD18HLYWCs9kYQDhETovzUcy56CWxhE4RuCYBY+G
         ZSBorcdELrGWvCbMhw8jOa+lrMq2JOtSZXmW7qEP4G7nXavdEVqjmG0T/2gyu8u1I8j+
         H/bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=8ShUaFNcZ5bsBda1zqagRP6x7qsp4WEK4DhvDe+5Rtw=;
        b=hTclJc1v0FrM2ACiMOpyZLGu3DSxfv9Y/H1TNpSbAsfn4qY5VsdlqjF/MhzXY2ZX1D
         ZnYVNT5SVNWVDJyLAc7E2t3Ot+r/7VzIdBkAvT+AsPKvYx5/uf1PTC1yR57AFjEp4HdH
         0GyuNdXBQ7RBosQuJNqcFtsYuaeqqnDVAsfGhJ2cvVSTtv1zNpqXJlDkSl1oZ+2k3o/L
         VfShXcDYgo4PfQ4yytn8/umIzqa+HMlKoTi9M/m7XRc12uV1/7cIz4ygjI3xNJp3tc6V
         h7LiO5xXh44AC2IoKtCLgC8xHo05Oko6lodNueQLcIZod51aeI1ius2F3HxcqnZg8GEP
         OUMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UdrlvXS2;
       spf=pass (google.com: domain of swkhack@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=swkhack@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u71sor14081161pfa.52.2019.04.22.03.38.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Apr 2019 03:38:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of swkhack@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UdrlvXS2;
       spf=pass (google.com: domain of swkhack@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=swkhack@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=8ShUaFNcZ5bsBda1zqagRP6x7qsp4WEK4DhvDe+5Rtw=;
        b=UdrlvXS2ETIdt395/IwHQdgQ08T0mVB8OOoD2yCuJxMEckn6sdSLY/ltf0KqsPn25L
         F0a1HS0moaN4aXGz8DNvP6RB2+obSdXzTo2nCwe2F40xHt85H6go2aArGQm50ujLWHfh
         lXU1/N/cfJulz4YNfOtASO10KSiJ338Gb400MNzpjb/F4v+JHzAxx3OUtcJLXUf4zaZI
         A/HMENe5eI/ldswg+q/rNZHWLhLApKUSX6CQ+IIX1Re0y/7VrjEIPU41cZC/Cfo4h89M
         xvprhbab/eYp0Zk7niNvbejVlXXt9A6Ize/RWzD9acRSmSw/sDSbJIGfrn0Kv3l67a/r
         UEDw==
X-Google-Smtp-Source: APXvYqzcbhJjU+E1kE/vP3nKLCghCNJ3GWcQJuOwOgpar8jx+J/5M8T8m51itSvisFIjAwWiXOIPBg==
X-Received: by 2002:a62:ac02:: with SMTP id v2mr1463566pfe.163.1555929529565;
        Mon, 22 Apr 2019 03:38:49 -0700 (PDT)
Received: from localhost.localdomain (ch.ptr162.ptrcloud.net. [153.122.97.60])
        by smtp.gmail.com with ESMTPSA id r87sm21596546pfa.71.2019.04.22.03.38.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 03:38:48 -0700 (PDT)
From: Weikang shi <swkhack@gmail.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	swkhack <swkhack@gmail.com>
Subject: [PATCH] mm: Change count_mm_mlocked_page_nr return type
Date: Mon, 22 Apr 2019 18:38:36 +0800
Message-Id: <20190422103836.48566-1-swkhack@gmail.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: swkhack <swkhack@gmail.com>

In 64-bit machine,the value of "vma->vm_end - vma->vm_start"
maybe negative in 32bit int and the "count >> PAGE_SHIFT"'s rusult
will be wrong.So change the local variable and return
value to unsigned long will fix the problem.

Signed-off-by: swkhack <swkhack@gmail.com>
---
 mm/mlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 080f3b364..d614163f5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -636,11 +636,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
  * is also counted.
  * Return value: previously mlocked page counts
  */
-static int count_mm_mlocked_page_nr(struct mm_struct *mm,
+static unsigned long count_mm_mlocked_page_nr(struct mm_struct *mm,
 		unsigned long start, size_t len)
 {
 	struct vm_area_struct *vma;
-	int count = 0;
+	unsigned long count = 0;
 
 	if (mm == NULL)
 		mm = current->mm;
-- 
2.17.1

