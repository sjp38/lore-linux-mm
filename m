Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3ABCC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77034214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ERfk6YwV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77034214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DF728E0195; Mon, 11 Feb 2019 18:28:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B7BB8E0189; Mon, 11 Feb 2019 18:28:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A4718E0195; Mon, 11 Feb 2019 18:28:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9AF58E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:19 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id y85so235736wmc.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ktrl99/4+i4VLz6USppssXo49kPq9nmcbGTF0KLoSBQ=;
        b=Fp6rWSipIfHmPYLRs5To0nlNMw3yzTAGWUxfazkqdPXOXhmuZfPm88zwkcawTgAeRm
         hmEMSZ4iBRCSFWgyHwPFdUqkiaIIHrp9hIRMlnZ81QgLjUoy4RmrsbwtGJzt74rKZU3O
         gTasceeAckEsBIRpYncpz+W4vQ9ibZs6+KvKeokWQE9Sfn5pCYcxHd1KoN/aw4trzwBy
         WOGZdHw/myX+FBJRcxlcPgS0OgMDU6K4FCunoZmx6jG4Vyk3dwbyJUzaHjl8kDT8+oJ/
         avJ/qKnlRUjyFhIAwA1bnAig3onkw87NE0KkSP/bG5e6X2Zhux/ZRChAykLEWZ5Zmafn
         t9Ig==
X-Gm-Message-State: AHQUAuYquMYZHML44pFseyToMbY8fKjhhsQs5ecAxYRROLH/gfCpjVpY
	btN0Em2f7UyRW4P992ol+SziJyUdkgewNMMZBnYj2w5FJgtE6GZiwKL9qh0EmCJpByj3tKeXeHp
	yno9aWzplVXBYitQNDClwL61YP0nDBbQgBIuI3KzngKa0IEenLW8juUawBEKFW2U8x/X7SbjeIx
	6PVDWMsyo7ZkBc4yNnfLUcpIOL3JAxHJujOnE6A9YXM4d3nel540nZu5Aw7ZsWwDbt1B5fbEcuq
	98CWlBbNiXJfpS9HRm+x9Kj3xDAEUPL2BAl5Z/F4axO3SFap+OB2EkxruJ3m54s5rJqiOnec3Ap
	TZbqtZBKCkKpUszGTzjO1C9fL6icDmspQKpbQ45Cu5ahU6ywQ4R1aR6HqHmsusV8ygwTaZvQwJa
	N
X-Received: by 2002:a7b:c315:: with SMTP id k21mr442168wmj.145.1549927699136;
        Mon, 11 Feb 2019 15:28:19 -0800 (PST)
X-Received: by 2002:a7b:c315:: with SMTP id k21mr442121wmj.145.1549927698144;
        Mon, 11 Feb 2019 15:28:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927698; cv=none;
        d=google.com; s=arc-20160816;
        b=eGz+xJUR+f5+Y5sffnzQwFO1tc6eeyUgtiZHxg8AlPVVsv3rYetoxdHZ9bZR/IYDI+
         RRycdz+jJnawtZr2UcYrIuDCJ6KZ59Vc51ar0Xp8Ba6qPDlfKkoCusJjKRywTTfMr/Ia
         cwmQKFdYzipgzwUd29oxzS/D8tfSdPw4WSvFMTlVrt0kM4lIgXPclzxKDmTQOAt3l+Ik
         HpA1vi/FHYyoVidsyGxAtnxGbTAvzCLj++G9tgxwtp4aP3jbJKrrQVHf5xhPfoIMHOKT
         f+KwwX6HTne10PDmxq2y6fRkI4/mybhYfLk2sDjO4WnegLuj2vnxEa5lZYjBTphRFR+S
         Xeyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=ktrl99/4+i4VLz6USppssXo49kPq9nmcbGTF0KLoSBQ=;
        b=KtukHwt/tmrRwAWiyY1i0krFWTl3fLWh1iNoCGzt8RWu6wwWUwZRx6Eh9rGFj31Hzi
         Sp4huVKhlzt+cqFWaGb3p6RqajsdGTV8ww7gZvtYLtlgxNQGwcecE+bbfZ2z4cCoqMN8
         UySHOJiXl5+V2a1Rj6h/gvUVL6698rETt7CWnMlbOvIAlAAMOeplGz5VKiHFEIWB0hOI
         4Q6iAA7Pq6uZsG7HaqsKGqoY879Mvn4pV0CmivnVzNKDvi/NaIVfLmSbSW3FZ7bFSjzw
         z3dyOcbDJSe3cKETw62pNp5PBApdt9pj3lfvWwxPfnMzl3O5s1FDZ/SeURzrag4yy5Gb
         lrlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ERfk6YwV;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor487960wmc.26.2019.02.11.15.28.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:18 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ERfk6YwV;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=ktrl99/4+i4VLz6USppssXo49kPq9nmcbGTF0KLoSBQ=;
        b=ERfk6YwVVFsD4gpa86J3tNvUf/jRxA7negb6JBcQ5PSR0xZZvMMbnqTZ+wRrS2Husj
         Ggd8+h/Q6iGpIBl92FmkpdpssV2xt9w6MiuQS2cXjMtk96NDjzsy/uEnc/s7yXVpuL6c
         mpoDNWR+cp0zbAXtobA5UoCkq+orGEc1HmBwrLmgLHRuHzaFQ/+tRBnFd/U7BP3qfbPV
         ln/K1BHTqeaHXoV9cT0aGU+M7Xa55XRzuBeoCYotqmiST1osgENBFvz37ywgrYEko+pv
         OnWJ8Rdek3QLL7gzQPr7kKm7jyZ28jH2jgCwj74BAERzhEIIn+YrVvRGcUeyx16kqW+P
         hxEQ==
X-Google-Smtp-Source: AHgI3IaPnxVvWxLjhqm0PsH5iF2NiueH7C1Z1h4hq25QVvV24PnbiOHB8xirGOEnJlaL7jk97tS8SA==
X-Received: by 2002:a1c:7719:: with SMTP id t25mr513964wmi.7.1549927697736;
        Mon, 11 Feb 2019 15:28:17 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:17 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 04/12] __wr_after_init: x86_64: enable
Date: Tue, 12 Feb 2019 01:27:41 +0200
Message-Id: <38307f2c7ae982478d33f55f7a7b827de489cdf3.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set ARCH_HAS_PRMEM to Y for x86_64

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/x86/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 68261430fe6e..7392b53b12c2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -32,6 +32,7 @@ config X86_64
 	select SWIOTLB
 	select X86_DEV_DMA_OPS
 	select ARCH_HAS_SYSCALL_WRAPPER
+	select ARCH_HAS_PRMEM
 
 #
 # Arch settings
-- 
2.19.1

