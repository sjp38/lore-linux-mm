Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70621C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31ECB22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sbZR1J1/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31ECB22387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F7E6B0007; Wed, 24 Jul 2019 07:41:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0F636B0008; Wed, 24 Jul 2019 07:41:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B25848E0002; Wed, 24 Jul 2019 07:41:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8BB6B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:41:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so23971681plp.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:41:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nqvsbl2w9ubgA5WmXqlNPepTd4gyiLD5l4bjkw0rY64=;
        b=dRsdTEaEl0EXFsQIPTfQCUMDDIqdWDA47DobdDr32cK10j/FJPsuauDsAaePbSn0mE
         v0tVH8tND8cJ2/xHHEg+mbpHJXMUUL08nNVjFz8qDnf6absp9ZUE0BU2SZFQ8Q/L4TTc
         VF+6D2Wz8Ap9tpuozIRRruo2pbIlkaqgYokbws1zlMa830tzGS0Wrmy5KX/C+SGSzIy/
         4+LG6uLlhSSXJYYY9b+AM3UMLjgVGs+Lf3SdFfNdkZC0MFTJaSSf7EM9P4GSIEZDWWj0
         VoqDtKrZoJuX0refG9F1bkWEtLKa8TTobwC/Pgv6OYLULQhAXrjOdfSCv1wQUWkr72iL
         k1Vg==
X-Gm-Message-State: APjAAAUMUbf7Fk99xlud3z3om2k+ur7OjoJ9nhkwa5PpvppRQ51Egra1
	jcswtU6RFyu8kp3a/XKcB6FSr04pREP2sR5rvM1sDOBH/yHjpp2daw1c6UgZ7WE3lyruW7wMEQQ
	mHZ+JrcsEduxZRbmuyu+xvJ6DxCM54WLiQBiZyeZfgiftfE0fJJBQwDp6n5+sjSuATw==
X-Received: by 2002:a17:902:9689:: with SMTP id n9mr86664463plp.241.1563968496002;
        Wed, 24 Jul 2019 04:41:36 -0700 (PDT)
X-Received: by 2002:a17:902:9689:: with SMTP id n9mr86664404plp.241.1563968495169;
        Wed, 24 Jul 2019 04:41:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563968495; cv=none;
        d=google.com; s=arc-20160816;
        b=Rh8MyvSZq7ndHFy1SD8LwlyZQrFuXTjfRZt7ueyJaNxF30sel9FQRPW11ytEkg7rJw
         tRcV10lHLxrvRCrDKBKXHnrwTGUyPrlvnFNL6TVgcaAky3k8bWx6OurEHN24jJUdkze0
         zB9NvzcF2miwjHLs+N/1Z4kH0srn9nY0uxKy8W6A1jfD6QGUkEWv2OyjnCjF8bEGg0PY
         YPec2j3ZP5rvd7UboZ3qudxcsqCZ7WZcBXk3oFjmOHliFKnuPSyh9BiTX2kLWiobv+uE
         +R2COqTHMvA7hYpjgvOQINuPGOzCJ9BlEQjWwTDSQ5dlEnUCwVDQCEVOMjTfM1kXgutK
         8Ssw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nqvsbl2w9ubgA5WmXqlNPepTd4gyiLD5l4bjkw0rY64=;
        b=D9I5Nuq3BTeAySf9WkLdThrLDGoA4/EAJhIgMbTqL1gd2s/dCHN26Mq5WK2q4yOL6/
         A8qH1RvFx06UkbNZQsU7oQusJdcTnd0ReJYczvveDNvWC/ZOzEB6saHuMd56xB56pab3
         8CnuuCJaneNMxc+mW4COGpND4h1aOdq76YOh6bqa16SzmlZ6FBvN1NhNGcjiN3PfHyxT
         2wei/SSnmhSV/uIooNLFn7+uWz3kAySStCSbEqGdua+5Llu5dJUOrqEh5UJ/W8vY5II9
         A8AtzlvapXXJ0ktBaA6EbMYjs3NLbM3zcMVnvSTl1bn3w52woj+7flalZ0mei5ayTulX
         sEBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="sbZR1J1/";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor19896112pgn.1.2019.07.24.04.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 04:41:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="sbZR1J1/";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nqvsbl2w9ubgA5WmXqlNPepTd4gyiLD5l4bjkw0rY64=;
        b=sbZR1J1/xqSfxGhYdGe1aFC5Zkv0bIcVVCiEERD1YNPQcvJu+dI2eJwklfIzWnOinC
         wgzv6UwGtypD3oNxaNtqomTVBIb1YN0lcxHk60raGqu7gC9U3yuj0AO5dyeTmlDq2wsE
         tz9vqtq+shNHs/qAQoJ/Xohi6S0hphqNq9B5rBnNOtWxxfa2CCfaiIStlWKpcoFNQcOA
         NHaJuSgyUQB6cc3bli+/HQb9uC9mmSODW57RXUZx+2W8FXHIwa7POYv9odL8WsPcNIa4
         ol+z5m2bndZA7uWkCFqwSXnG8oKhXqGUmzpnAycP/R6yUpBIR57luL0M0fwvfH2wLoah
         6uIQ==
X-Google-Smtp-Source: APXvYqyslSaLqtp4I3vK4ITATRHG4NBqTSovhWR6FrUXhe3TD7S2jUbFqr+lU2cQJA3rJYRr2NHLFA==
X-Received: by 2002:a65:6850:: with SMTP id q16mr44415063pgt.423.1563968494767;
        Wed, 24 Jul 2019 04:41:34 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id b36sm70730923pjc.16.2019.07.24.04.41.33
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Jul 2019 04:41:34 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de,
	jhubbard@nvidia.com
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH v2 1/3] sgi-gru: Convert put_page() to get_user_page*()
Date: Wed, 24 Jul 2019 17:11:14 +0530
Message-Id: <1563968476-12785-2-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
References: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 4b713a8..61b3447 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
-	put_page(page);
+	put_user_page(page);
 	return 0;
 }
 
-- 
2.7.4

