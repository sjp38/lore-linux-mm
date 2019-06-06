Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5B01C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6833E20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="awv3zzYY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6833E20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 906D96B0283; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88E2E6B0282; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 509D26B027D; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8A96B0280
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n126so2748296qkc.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=i7+8VVGKVPXEVnSFQY2/eN+heRnF32oClEuR9RZcz4c=;
        b=ZAnaYYj46DLWLeZQMLUGac0Cse0ZPNgDJe1JYHzTFCxaMRvgZlT2cA4WySk0oOgGaN
         O4okVW/4x0TfGIRRWn4uxOKseHk2qaxKUqJQb4eJ0pogXAjFtxu9IeVmO0u31818dpPE
         Hcorl4w2BlHNW75n5BsKWejzc7V9SM1b5an01+ulth9mttIVvQq2jvR455Jax2n8Hph6
         zb9dYJCYtfmMJlWEX7729oEDgUwJPKwWGI3j6iViNQpHoLAxWBC8nQDvCTBFD1/d1++9
         Y3M3L+yHFka6QGZmC3Jic/jWJt5HegtrFgXUdx4fSOm6GfFqMDGWKVaMq6T3ObfAtQrC
         pwgw==
X-Gm-Message-State: APjAAAVBDs43v7ae8fFmtHwYude1psCEwzexQXX3+jBwH0ah17UcgzPx
	XiZn1I4YixUAyBWpff4yBUGNPkdFhMg726wLCs1Y/lUh0kOBS2ORDIM7Vm48d1cBwUd2MNtxP3B
	azFcssY3M3q/UN2ttuzhOvXdy6birJmTRME7bcxguQ5ufEnOKivQCDDCBs762Ubs9EQ==
X-Received: by 2002:a0c:95ed:: with SMTP id t42mr7485056qvt.70.1559846688818;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
X-Received: by 2002:a0c:95ed:: with SMTP id t42mr7485011qvt.70.1559846688141;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846688; cv=none;
        d=google.com; s=arc-20160816;
        b=LIjZQ//q6oTlxWzXX6CKLHGsPkXlpxwjrk81xeVBf/yv1e/+L8eXm5JVElgNPtT+by
         fOoPya/tLpBjRXJm5nU5YdZasVf8Gr6Z9sDOd5RuDQDdcC533a4FrqS3s/CHKdhlH1sA
         LJdH2iBZIwospbhwaLNNyH6eQVBgaZH5RpC7xgeJt8u9zDNpms6d0fmLwoY6Mq3Hm0GI
         mPZX4vkbZmMPHqJZIn9EHG1QGGGTVFWxgaFDcUZ5SBf0FJVERSKYymxeFyCVCgEuvVGV
         fWosT8ruiT1fYwsdFjopu0p70XH/WlkNMM9BvrjCcoytw7r/A6qd2LmqkUftk0J6OrpZ
         9Mhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=i7+8VVGKVPXEVnSFQY2/eN+heRnF32oClEuR9RZcz4c=;
        b=uCDbdvRQGmK4gxzZkZlfyqFrNwUHSCqBXzgM4MF97zyTR3ASK9o+mAijN+ifs+z3OF
         4N9XWYp35FO2p/8Tr5Y/CXccw+Mk9/MM4y0ilao2VLeyhvBLKa0kovS+EXlYPEDjxK89
         V85avDkYNXe5LdFNJkOZXuC4JgazuVoeDePU6zrey0NjvjWeKZ9Zm8q2ZWShSnEL2bye
         cyXJwIus8lXdsvgc2nTpTIKXR9kT/3J/Y1sWfjoTCkEcwTsakrlr40nmw+FgdGbhDklU
         eR8mOh18eYm2hI6jj1s9rmPJsYROwOzwiYnk1l6prWjiB+PE3fjG3EtbqxM6hVUCx/lt
         Emng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=awv3zzYY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s64sor1455652qkh.114.2019.06.06.11.44.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=awv3zzYY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=i7+8VVGKVPXEVnSFQY2/eN+heRnF32oClEuR9RZcz4c=;
        b=awv3zzYYkAzknK7/NkCAiHR5B250y04djNp+WoYpexe7Uej2IPZ5cqDxrJR0439HDp
         Ip+tkYncoM6synNyttQstYPfXOCfvqJ+MFaPA020vji6f3V+ijeewe00T5WLlGVbBkip
         ta/ZcbdijmmX7p+PqFRh9FOoQWxBygNZCZjmbhPstNfn/mX4xsgnW1BaTUSYo/a8jPup
         YkMIRPOwMicKl54A6Y5BoXPtSil+jxKqN6rTDrLm8CETdgRy4WQzp8exudHeoEcxgA4t
         JqZxvdcH0B1B5+3aq+YyPAmAifoH1FgyXvEu+EF0wwHDyoaCdNCX+I1ObXgN34um9W9p
         meJg==
X-Google-Smtp-Source: APXvYqzcNAbWl+BqHtgTaqiaVwnoaAOHy/kM0yjt/wGvoT6pCtDHNXa8FJTB1/3g0VUWQOgRUAVd7Q==
X-Received: by 2002:a05:620a:1ee:: with SMTP id x14mr39905952qkn.70.1559846687875;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f6sm1303617qkk.79.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008IT-Km; Thu, 06 Jun 2019 15:44:45 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test before wait_event_timeout
Date: Thu,  6 Jun 2019 15:44:32 -0300
Message-Id: <20190606184438.31646-6-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

The wait_event_timeout macro already tests the condition as its first
action, so there is no reason to open code another version of this, all
that does is skip the might_sleep() debugging in common cases, which is
not helpful.

Further, based on prior patches, we can no simplify the required condition
test:
 - If range is valid memory then so is range->hmm
 - If hmm_release() has run then range->valid is set to false
   at the same time as dead, so no reason to check both.
 - A valid hmm has a valid hmm->mm.

Also, add the READ_ONCE for range->valid as there is no lock held here.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4ee3acabe5ed22..2ab35b40992b24 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -218,17 +218,9 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
 static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
 					      unsigned long timeout)
 {
-	/* Check if mm is dead ? */
-	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
-		range->valid = false;
-		return false;
-	}
-	if (range->valid)
-		return true;
-	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
+	wait_event_timeout(range->hmm->wq, range->valid,
 			   msecs_to_jiffies(timeout));
-	/* Return current valid status just in case we get lucky */
-	return range->valid;
+	return READ_ONCE(range->valid);
 }
 
 /*
-- 
2.21.0

