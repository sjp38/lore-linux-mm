Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE28AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A212421773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JIjtmXhI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A212421773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7B8E6B0286; Thu, 23 May 2019 11:34:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C35226B0287; Thu, 23 May 2019 11:34:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7F556B0289; Thu, 23 May 2019 11:34:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 833CE6B0287
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q23so5683311qtb.4
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fyMd/20M9wRDEt2CUwmbtJJl1RcuuD2R+QgKbl3Q/tc=;
        b=o9lAfMeYwWgusnRwOf6T0VNDPf7BMgWP9FsjAxWTXjiVLvTE82bnAepiamUaGUzgcM
         VYdtIhOEBpW3Q95SKE+Icbppo/vnvAOxkCCPfCPp7sw40cdbhgkJK7N/vl+GbjtJiWF/
         PYkElMsmV8ZQCYi+fAh/8KoxzL57PT6BAMOF3hWN7xz+4MLma1E4xiNjwXpywYcBW1Ii
         WUvRVqKjGd1tamMByAds6auMn1LCFiqWhWBq+vabsK/6vPoay5MZvBGWUEtwBoMuOt1o
         ULvWBWN7s8XdNQjtejLGEFX55o7UwZASVryhWOwlgRk1j33qRDLpBP3uCefgQQP7atEQ
         E25g==
X-Gm-Message-State: APjAAAUlNgbWFAELDy4D0GGP07C7ej4pLktbED5PN5qZ1PSrJIh6cv+w
	MViyTUmQr3j4J4RbU3pm2vW5XcPlUI/pjwd2NEJs1FaRYFqahPJE8cRxU0wC9hRm85+B9tN9JJv
	mzue+3OceAJED23Av4vy/caRnx3iKTSSdNAqwGr3yn8zgZNzHU3Y90xG3goZ7MwGU0A==
X-Received: by 2002:a0c:96c4:: with SMTP id b4mr65427755qvd.2.1558625685293;
        Thu, 23 May 2019 08:34:45 -0700 (PDT)
X-Received: by 2002:a0c:96c4:: with SMTP id b4mr65427672qvd.2.1558625684313;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625684; cv=none;
        d=google.com; s=arc-20160816;
        b=i7jf/sxWaR9BSuUpNb72LI5K2khoePh6J+8SUMCRhZY3sTOzXbhX24VLCxrCKJzjeF
         ySjy2b7xxuxcSVk0FgCcXVVYmvtZR91ZS8VjfpNSXK6zjB+MDHR0+ZtqnweeWagZT7fN
         5xD0Hg6Y4mnhW/c2XMYxiOqhkp2ZT5UC73oumhB40Zp9eNxutval7eUIFW7Q0sdFoZuR
         +lU8oQsf387w09U+NN3wqPl8qJpQoQh4K6a140XXXfrlDkTWUIldW6dapMbM3/U3mfuT
         GT/71S5IxIgcoQSHPj9rAyUNqTxuqxNw7niHN+LSMnufBPs7/OH0S/f2HTYHJa5CjVCS
         AB4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fyMd/20M9wRDEt2CUwmbtJJl1RcuuD2R+QgKbl3Q/tc=;
        b=cHs6D8wJld1LuqPjLCFKQPr+GNrmqEzjmELh1XLurOWtHJ6w/Y9i0fsYueUeazzNRY
         WJTx6ypsibGTgaXhvKl5Ej6LoiNTnZJNuNBxaZjJGp5HZoZh8s9bfaXQ6fnrarYrqd+n
         0lFhaUNvZe9jXCyp7Lj2yC9hmyIRxukRsGphesLPc2t6vkh3rU2EwtVkzXiRqYOsfrK2
         y/dkaj6uql5jM3HR+Uvg5GsGMal/6C/57HSyqGMFuo5Ck4xwgTFM/XCC+MChkrpU40v1
         xIRwCC/oRh50tw2EYgNaDPIzaTMNv+t326YnpUNurqq27LYROl5VAWFiy1zDafe7a9De
         m24g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JIjtmXhI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t42sor603789qte.28.2019.05.23.08.34.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JIjtmXhI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=fyMd/20M9wRDEt2CUwmbtJJl1RcuuD2R+QgKbl3Q/tc=;
        b=JIjtmXhIk+ouBJQ777LOHATYHiCxeddr9NRCIpfSEdrQ1ap9ixS0CW54V6HURwC9xA
         RKpjT/mKs8jM8bOrU+JpE9OrzRhV1PSZWwxlmuIpZMYfSawM5XO76xU4PAAGkcWLSm5s
         7ndty4jjdbxARiXmFK166PeUPWVyFicpugoKluqPMkVT0YjQEoLXox9cyoZwmEcFagdx
         vDMEFLfHF1VypHEJSnZkoDjj4S4j7WOn++WkjrFxWKF7S2FzamGOtEw9nQxisne15cmS
         QxE2dETQ9lLxC5EcMBOuIOrkEj8esYg8qdZuZD+Z0aF0lIU814C/ZVRZzLowQaUo/lk1
         YE8A==
X-Google-Smtp-Source: APXvYqx/4tQV+dyjpchgQ23NYg/m02UvYl5N+Rh/idEA6TgEqyIlzTWmi6NKvXZCk10ahm2Boj71vA==
X-Received: by 2002:ac8:7c9:: with SMTP id m9mr15162695qth.127.1558625684072;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id t17sm17461892qte.66.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-000503-9i; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 10/11] mm/hmm: Poison hmm_range during unregister
Date: Thu, 23 May 2019 12:34:35 -0300
Message-Id: <20190523153436.19102-11-jgg@ziepe.ca>
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

Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_ON
and poison bytes to detect this condition.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6c3b7398672c29..02752d3ef2ed92 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -936,8 +936,7 @@ EXPORT_SYMBOL(hmm_range_register);
  */
 void hmm_range_unregister(struct hmm_range *range)
 {
-	/* Sanity check this really should not happen. */
-	if (range->hmm == NULL || range->end <= range->start)
+	if (WARN_ON(range->end <= range->start))
 		return;
 
 	mutex_lock(&range->hmm->lock);
@@ -945,9 +944,13 @@ void hmm_range_unregister(struct hmm_range *range)
 	mutex_unlock(&range->hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-	range->valid = false;
 	hmm_put(range->hmm);
-	range->hmm = NULL;
+
+	/* The range is now invalid, leave it poisoned. */
+	range->valid = false;
+	range->start = ULONG_MAX;
+	range->end = 0;
+	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.21.0

