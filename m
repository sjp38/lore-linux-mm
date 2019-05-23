Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3417EC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D53B821773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="jv6BZA8C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D53B821773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01FA76B0275; Thu, 23 May 2019 11:34:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EED416B0278; Thu, 23 May 2019 11:34:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8CB56B0279; Thu, 23 May 2019 11:34:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B73E56B0275
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:41 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g14so5645667qta.12
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZePMKZ7jqBhopBdwVcCn1CrsRsr5VRg48k9A7BJXYb4=;
        b=ouA5FfzAkhencLhHyy2LtcN63Lg9dI2UC69W27l7yKpTTZI/q8Bi8gW3guPtiWRv9P
         FUFTXc7dfd8Pip2jrULFlNMUpqnloN6IIGhSgdfTRP1Cq6E88zOFHBRbe8+f+JRXski5
         7ev5Dma2eZ46QQW00OvAjlUb9fFimTsW9Le7HbmBuOMI9uiDh7uUhCeDz5NUVDR8DA+9
         l4q/h3omcQm6uKW6ZQhVDwTSYcGexTuyBZA6tBcXUBN55cEuXUlC47PfDeOMolZmXJEH
         oPOumqRPLsmnc/N6oV5VOeiepTvd5bCVh/nC2wtx34+ZxRnAGve7g/UabbptM6YJGuhi
         OpyA==
X-Gm-Message-State: APjAAAUbu2GyzQkkk1czKHSkalqL+9cfH9ertWwcIgnCl1xBJpasLVT1
	/ntvTSH9BrbQS/iKa1F7jWydeD8yw/pvY5T/D0NPDrQJnSwGkbr53e6AFgsM64wHH3FDl4CM4gl
	40PLGwfilHlqj6eqfMyv7y6XAAuiPRQZtTAR9ruNvDRC77laH1ytaeT4XVLU91qMdyg==
X-Received: by 2002:a0c:929a:: with SMTP id b26mr77569594qvb.148.1558625681486;
        Thu, 23 May 2019 08:34:41 -0700 (PDT)
X-Received: by 2002:a0c:929a:: with SMTP id b26mr77569475qvb.148.1558625680352;
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625680; cv=none;
        d=google.com; s=arc-20160816;
        b=vtFuxeG4zv+8QUG1h77m0ctKjAaMFiGJpz63qWwH6Sm+nq3P1LQvAIMlBz6v3NBHyM
         jkw6HdHux2LLzLdAWZ/PJFdpGHc/Qoe6I9JuIya6db2MzuEIqaf5EGJ58lanwYo4kffY
         YNiXB2/qYjQD5u5+1Ozgjkmv6V+VzIpWlGsoQBxlsq7+rVJEn/X0O8FPHeKhvJDXG4sI
         CHncll83aPr+r1yLUzlw2gQH4vHebIj4LTHkfVve4yCpyb/q7ZZdmLZPZ32XI+CiaGCV
         J5rNpHEl66nfw6Hhua6Jr7X8z7u6wNWdxcCMbsNhNNLIeWAgsrpxdNnluph3bdPdyIvZ
         RPcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZePMKZ7jqBhopBdwVcCn1CrsRsr5VRg48k9A7BJXYb4=;
        b=eYsl2hhL8IJ/fECEjHKYFcXh8gcdB7N6bUSyPQJmecPYdxGgh46IK76Hsqi3r329Fr
         bKxv0o38Pq5Wl7uNMj47G4GSdIzScSYCc0vP/FOnJY6/emRabL0vTbNZUqGuzSHei8GO
         30OTAo3bvuVZFr6rKlEoJZSwtDh6nFdKPad4O3Om4xxHFOYxH/YQpXFUTQjpCxsgTdQW
         KdZgwHPKZI/0PJm3Je9tDLgDI4gFYrc+aYrxCxoV47lVtfPUpccHkFrIQeO7tmWZiuTU
         wIEvQcWZsXEIoiojR9TeUPMJNvCLfGJRZZPEVlbkbfBC5FDlIfLSyDLUobyTCXK/x70p
         pymQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jv6BZA8C;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k63sor2739403qkc.103.2019.05.23.08.34.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jv6BZA8C;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZePMKZ7jqBhopBdwVcCn1CrsRsr5VRg48k9A7BJXYb4=;
        b=jv6BZA8C1NV02Y1wmdXHZ90xqpN8v3U2iUJqYKuvZM/jGdctWUbv+nypqASupEpUuN
         vIJUJzSEQT+oiGmCOeMcLnf/zJZZJYkp9fMkQWdbVn6lbTE2PWKG+0XU8rQzC0Hq7Y+X
         r1gaLm6hZu3mcuSUXfzmFexbK/YKvGzQEV5NqwCdYopvQ50bAWFzwmX3JWwZuuR6KItI
         LqdMy9kYprQxYkWCbGlKs8lxcUTCSD7OTwxmzLrQKpMbz0TWlcMw3K9W6VInHK08n7Qd
         2fajaOkWWQEZaJr0X7BQVoog4kSz1uBsRTCfvef4Gw8N0ebsa2yCNtTsdP4xqFS6YoQD
         xjuA==
X-Google-Smtp-Source: APXvYqzE9Wf6pPLXAKTOOnViH6zjZXhhQeJF2uy5/0EwAhBMsAqbYZTx1jGzOFC4t22sUwexJeiqqQ==
X-Received: by 2002:ae9:e208:: with SMTP id c8mr74383498qkc.154.1558625680068;
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id x10sm2553300qkl.84.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:38 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjp-0004zH-Uv; Thu, 23 May 2019 12:34:37 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 02/11] mm/hmm: Use hmm_mirror not mm as an argument for hmm_register_range
Date: Thu, 23 May 2019 12:34:27 -0300
Message-Id: <20190523153436.19102-3-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

Ralph observes that hmm_register_range() can only be called by a driver
while a mirror is registered. Make this clear in the API by passing in the
mirror structure as a parameter.

This also simplifies understanding the lifetime model for struct hmm, as
the hmm pointer must be valid as part of a registered mirror so all we
need in hmm_register_range() is a simple kref_get.

Suggested-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h |  7 ++++---
 mm/hmm.c            | 14 +++++---------
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 8b91c90d3b88cb..87d29e085a69f7 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -503,7 +503,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift);
@@ -539,7 +539,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
 }
 
 /* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_range *range, bool block)
+static inline int hmm_vma_fault(struct hmm_mirror *mirror,
+				struct hmm_range *range, bool block)
 {
 	long ret;
 
@@ -552,7 +553,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, range->vma->vm_mm,
+	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret)
diff --git a/mm/hmm.c b/mm/hmm.c
index 824e7e160d8167..fa1b04fcfc2549 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -927,7 +927,7 @@ static void hmm_pfns_clear(struct hmm_range *range,
  * Track updates to the CPU page table see include/linux/hmm.h
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift)
@@ -935,7 +935,6 @@ int hmm_range_register(struct hmm_range *range,
 	unsigned long mask = ((1UL << page_shift) - 1UL);
 
 	range->valid = false;
-	range->hmm = NULL;
 
 	if ((start & mask) || (end & mask))
 		return -EINVAL;
@@ -946,15 +945,12 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	range->hmm = hmm_get_or_create(mm);
-	if (!range->hmm)
-		return -EFAULT;
-
 	/* Check if hmm_mm_destroy() was call. */
-	if (range->hmm->mm == NULL || range->hmm->dead) {
-		hmm_put(range->hmm);
+	if (mirror->hmm->mm == NULL || mirror->hmm->dead)
 		return -EFAULT;
-	}
+
+	range->hmm = mirror->hmm;
+	kref_get(&range->hmm->kref);
 
 	/* Initialize range to track CPU page table update */
 	mutex_lock(&range->hmm->lock);
-- 
2.21.0

