Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21345C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 05:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCEA720828
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 05:06:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GHSeZ3sW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCEA720828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67FF86B0003; Mon,  1 Apr 2019 01:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62E1E6B0006; Mon,  1 Apr 2019 01:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51D866B0007; Mon,  1 Apr 2019 01:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1DDD6B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 01:06:17 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id k3so7096636wmi.7
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 22:06:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=M4MGvYBSxRWkMYqxZZ0sr2uSISFXxgLyKH62LoEaTXU=;
        b=oYcrVVg5CiiyKI4ahDT5c8XijYhSxoMfRMX/Ok0S4jeXWannrdCymHwFI7t0B9tI4S
         gsA1yKAPB7ng5rEXexKZi3RoESfvNFc2GiaA3G8uyM6cYl0F4rYVxfERbHjPemGIc5Tf
         1JR76nwOC8SKME8co+3cfMlYqBGkr6z+rlW78V2MalJ7IRjJXQ/RAmHufjLhaUedqxCw
         l+IEp1k+AoBAshrCp0V1+hNm18KlLV//BsdqJwZReQkQ5bdWIpXIwXay9O9qalmEiXwL
         QRsuAxYyIJM3vfVl8Xdp9DnxH5Xvl6MYxspn3ERZ0bH1ZTDOkG05TWuy+Yjn+8qzOV87
         1JuA==
X-Gm-Message-State: APjAAAVE3eBI6HjZ8tsccxg9yDF9+yy0T1TFzmcUiRNRyl01NBJKgdpu
	GLh3DaUsPcXautXWDt/gCjEFgMfjIFCxC/0tI4Nrxp2RAhV3kqIetDxpoddThAWnPgKKYq7nMC9
	U7KI6ITabhdjLwykVwAk0SuBFbF4K+wXfY1zY/uYxyIPWimEImQeBwYPD+69MOsj73w==
X-Received: by 2002:adf:b6a3:: with SMTP id j35mr39836375wre.25.1554095177432;
        Sun, 31 Mar 2019 22:06:17 -0700 (PDT)
X-Received: by 2002:adf:b6a3:: with SMTP id j35mr39836333wre.25.1554095176651;
        Sun, 31 Mar 2019 22:06:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554095176; cv=none;
        d=google.com; s=arc-20160816;
        b=VeLEQlchIhbHWH7rLMPvU/8ql3izTozoUHcr/nC77FefEzl2VwtilJzYD/sMuQlwp1
         0Sbe7OywPJ6nzTgmPpgstchAjmN5M3CSVvVzP5J6/6SyBgDcvxA0w9N8+YZGcj30fFxA
         ss4WiKnjWJxIoaklLm5XKXXb/3df+dEgYx/TcVe36QP/T4+FvRabFTx0SrFBKdaNhG7h
         v5KX9EcWvSWKFwMINKAUqFD73QVZ86d140DshJ37LAFqV6Sbe40LzAEUe3HS9a28NLxA
         5Ulk/1zmplGmDW2x/F8ae2EXapFXmHYez7L0zus6IbBr5u0A9G6I8Dbb1hbQsWlb01HS
         S7ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=M4MGvYBSxRWkMYqxZZ0sr2uSISFXxgLyKH62LoEaTXU=;
        b=Wxmg49fXEgY6OI6qGBGFqitFVUQMeX460i/uAKnJ0+h7MiIzWakZLxZAIZ9bI8MaG1
         FV+xyQorETyxXd4BCj+8z4XAo8LRCdBOHT1evGib6uOE/vI1zpihMAoKUQ4DDQyCXYKI
         XNJDhoo0T03qRFDq0SVw+mUqkDNJrkcFaFf4UN/ZOnRhHZQ8Yvjbtym62m6QThDJ5cns
         yVwo1ndDUn/tb1vFqEuo411AxZQIvDY46LHzrAdwogGj/pnfppey3u2OkDe/msM4p/Vs
         uXQSK+cIhfKMSCjJrlYb7tVfNa/+/H2qs8I6AoQ/GimziDBKL4a599cspeDPUijUKr0e
         fOLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GHSeZ3sW;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s129sor4949688wmf.18.2019.03.31.22.06.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Mar 2019 22:06:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GHSeZ3sW;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=M4MGvYBSxRWkMYqxZZ0sr2uSISFXxgLyKH62LoEaTXU=;
        b=GHSeZ3sWrmQE+TUXhZin5wQRMbtrv7tH4RE7yF4rjVdQuIJQbV2EmSAT1jJ9lGNWDA
         lv+bY+PrfTkoEwRJXpRnaxRUE3kz5pFSejgRlEOxYNXHOhY2joo1tc5PyRryMA0gGnbE
         EidVfPzsgy9FtXbRFMcDOyfU7mcZ7v9dzVMfnASHgGaSKls0TmOq7OhO2DBnSDwEpIGT
         JXHRR1PuD+mQ20fQVnFyZ4Vw6/PNkUk7zkwJw1TL3rgFua56BgmlSDsJt+hEMzNYqN6Y
         osKK9Ns9xGusRMddIyk6NK/V8aFtDr30it5b2FIe1JF1/GEcAz/hz9VeUTNWYEeetzB5
         /l7A==
X-Google-Smtp-Source: APXvYqxcheEGyEtUjehCK584yiEVKLUKrbJQZ31Qiv5F9Gr6VT9KcjP4NN934BHm67yFvbwzgWzmRw==
X-Received: by 2002:a1c:208c:: with SMTP id g134mr5714083wmg.70.1554095176356;
        Sun, 31 Mar 2019 22:06:16 -0700 (PDT)
Received: from avx2 ([46.53.244.145])
        by smtp.gmail.com with ESMTPSA id x5sm6811679wru.12.2019.03.31.22.06.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Mar 2019 22:06:15 -0700 (PDT)
Date: Mon, 1 Apr 2019 08:06:13 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Subject: [PATCH] Bump vm.mmap_min_addr on 64-bit
Message-ID: <20190401050613.GA16287@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No self respecting 64-bit program should ever touch that lowly 32-bit
part of address space.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 mm/Kconfig       |    3 ++-
 security/Kconfig |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -306,7 +306,8 @@ config KSM
 config DEFAULT_MMAP_MIN_ADDR
         int "Low address space to protect from user allocation"
 	depends on MMU
-        default 4096
+	default 4096 if !64BIT
+	default 4294967296 if 64BIT
         help
 	  This is the portion of low virtual memory which should be protected
 	  from userspace allocation.  Keeping a user from writing to low pages
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -129,7 +129,8 @@ config LSM_MMAP_MIN_ADDR
 	int "Low address space for LSM to protect from user allocation"
 	depends on SECURITY && SECURITY_SELINUX
 	default 32768 if ARM || (ARM64 && COMPAT)
-	default 65536
+	default 65536 if !64BIT
+	default 4294967296 if 64BIT
 	help
 	  This is the portion of low virtual memory which should be protected
 	  from userspace allocation.  Keeping a user from writing to low pages

