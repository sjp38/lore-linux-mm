Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3F5EC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82C44216F4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:09:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uchLVR9y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82C44216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CF3E6B0005; Wed, 22 May 2019 11:09:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 180F06B0006; Wed, 22 May 2019 11:09:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06FBD6B0007; Wed, 22 May 2019 11:09:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 900756B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:09:52 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id w18so457373ljw.8
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:09:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=cGTV7bQqwG5x9oiYauaYTWncIqmQlZcM9EHf5YH/t2wXnPTLXIq0I0xSoI2XRGoAS/
         z2XB61jNfHKBrTs2fUthH7eDi0PFS26webRU+qei+zbW9XHRhnRb3tc1ca/gL/ryb3Ku
         NpLCoN6DTc2GfEbtsY5zeSLnnlMxBjKBhrQpqVyXvp90HOvwxZhy4soEcyjbz1Uv06ul
         SSVlcztZvbhdAs3PT0btcqvCC1zUVZ+X84CWzX/nHCL+7wh3GVE2Bk7inX0QkdV9GZ0B
         7sQozclzc2hIBuRkY1RDr8iiQhurWy0eWv7XnjInC/MptsfzA+nEB7f/aderJYx8Nxrj
         C35w==
X-Gm-Message-State: APjAAAUdaEqeB1z9w9JgxoZfkeM8ASmdzr4ndiSfVQSkkPcWc75uFAA7
	hU2wGd1kvhcyGT6oNbEt4iyNELOgzgSL8kBGuWT343erM1/kznp7Zbq5RLi3ROwIrTUnGxN7ntI
	bcI0iijBEKVRVzMxyUrpdnRMVYVaDA8HvEOOcIxeIgi714ooMgSDtvR/cYWOjY0YDSQ==
X-Received: by 2002:a2e:9b0c:: with SMTP id u12mr15208028lji.189.1558537792015;
        Wed, 22 May 2019 08:09:52 -0700 (PDT)
X-Received: by 2002:a2e:9b0c:: with SMTP id u12mr15207973lji.189.1558537790831;
        Wed, 22 May 2019 08:09:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558537790; cv=none;
        d=google.com; s=arc-20160816;
        b=D0j3G9N+SuWyixydrl6kfMQxQjR1hWP8kwgfb6BKmU++h8aI+4AJ05Uiv68eoteKmq
         Ic56XR25264W+7BsaSy88vHU3V/czz/PgjOKEn5cEwUE0fEEKRjTLng4HLttdZ6ojl+/
         5uh4oyfFBFn0uuZYDUFAALw2bECdQigfb53eNqK8BUYdikliiU/gdf2zZzx69MS7Ch1e
         CU8Bsba26jFADcNXN/locE7wTVcHCKfvjpKeQAxp2kKw/R/CtJfEVA5QFHBcsDcKzXt/
         tEE0U4yyp3vRG36SS/ZlNDFZAhs27idvYsqsV2O50nrkzj1qCHTuJCq2Fo1SDlmFpjJc
         hrCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=RJl2BqcHugpY0FwAMdnEFFwUe1BTn5uOzp4LdnX52aM0VqaQZrOue1AIsl24zlkFxx
         i7HSQ2b0GFwwFoBqoRhQa20V6ZTB+ZcjG5H4cz80YUKQIWKe7HtEy9+FIKNQTDfVhGWR
         z4hOf3R5s3MU5M4hMOLI78KLMnPKBDtJ6/3E0cvdv5CHwv3l1/sLo2IeDCLwtQ01Sg8H
         ZHxT3D/4GGATUY1TLgxFhNOBfuMP+sYCOeiECHY1axUoNEyuUfAje1GbrNPz7viBoQqP
         NGO5r3ZdYcBIkqa6g4vHqZ2mLSffoTsdVKCoIS8LLwg+dPqyN40/bV8uJg0g8eqE24Oi
         o8LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uchLVR9y;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor7152925lfp.2.2019.05.22.08.09.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:09:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uchLVR9y;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=uchLVR9yDZbCoZFcLTDWBlnr+qGgHM4l53knuFUtS4cszF3qq07ggcXLTPp4f1w3EH
         j1IHk6vbdley5IzodGb/tQoWS8N0fMqt6Ua8kNPLmWewxcufW+1xVNb0e7fViD9CgcIp
         pJhh60QlEvljx7FQwox0+5OIj33+h7stGNT/5aqWO1weU6FRfCFZdHnUWEfTxAC5OMij
         t74E5/Or9Z4xug+txof7zAQd6NGIvQn4vfDdCBnBtueDJS3roYMhnTqSiVT58a1ZFUXz
         1chdk61oyigEWPE2i+mrhDPq+UCbJ9K7zrek8mWwqK7o2ecTG/tzzZbzagqaoi1i97aJ
         BgJw==
X-Google-Smtp-Source: APXvYqx5GGN3+wrZiJyukNG7wlTWckT2VbaD042N799w2UxWzlHPswK9PIYTsPn1Y77SbReZyTnRUQ==
X-Received: by 2002:ac2:5bc1:: with SMTP id u1mr41492644lfn.111.1558537790380;
        Wed, 22 May 2019 08:09:50 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t22sm5303615lje.58.2019.05.22.08.09.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:09:48 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/4] mm/vmap: remove "node" argument
Date: Wed, 22 May 2019 17:09:36 +0200
Message-Id: <20190522150939.24605-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove unused argument from the __alloc_vmap_area() function.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..ea1b65fac599 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -985,7 +985,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
  */
 static __always_inline unsigned long
 __alloc_vmap_area(unsigned long size, unsigned long align,
-	unsigned long vstart, unsigned long vend, int node)
+	unsigned long vstart, unsigned long vend)
 {
 	unsigned long nva_start_addr;
 	struct vmap_area *va;
@@ -1062,7 +1062,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * If an allocation fails, the "vend" address is
 	 * returned. Therefore trigger the overflow path.
 	 */
-	addr = __alloc_vmap_area(size, align, vstart, vend, node);
+	addr = __alloc_vmap_area(size, align, vstart, vend);
 	if (unlikely(addr == vend))
 		goto overflow;
 
-- 
2.11.0

