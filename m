Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75426C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44584216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44584216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36E7C6B02C8; Wed,  8 May 2019 10:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1186B02CA; Wed,  8 May 2019 10:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05EC96B02C9; Wed,  8 May 2019 10:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C02D26B02C7
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 93so9777312plf.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tOzY6YSnq7kQhl1Xfuc6nOLOEJG32H3j/0J5lRyZG10=;
        b=qykHlDYS3oXEDVKM07KyufCiIISTmMQSltRqNU/LgmnjDH8bbxwgKQbHPvIybnjZhc
         838/YX7lKirSk2ZA5zKQI2kexwmGbHME9gDYlSny6hrhzhH8cabMjbdsYNTiLmYj/pEr
         saR6v9agbAfs1Mz4SINhjYgb07RxgTbhAlwWcGYBu8HuXH4KSGY6A/UJ+z3BOxir5KLP
         WyhUDvvLbACUMbUA2S/Wcs9P+QZSs88v2vkFhLycc/2lk7tlTC4ESHB5J2jwBi6DNvnk
         7szmTY1UdY9kOZpQ9WAyVz1Zidf9PNzrdFp8kXpgnZ5lds+DwnGlAcWbutZMcgEcECE5
         mSYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU7GQRF5SJXbUpPKKvqxx8ODYDsFwthuIbVCq9afA05BrJB/GeR
	8W4Mzjkpb/1eICI9u9rthUhN6P2FIdbRq2G+i02+nvmPWi/wQV44JwY2FnJmPMUxTwofEjrWP8x
	49eKhn17759vUGIGGyKo9bTUjMeaGAnnt9XWTgqi7nCi81huUXQWaiKkPkWqpBNMJwQ==
X-Received: by 2002:a62:75d8:: with SMTP id q207mr8696094pfc.35.1557326787452;
        Wed, 08 May 2019 07:46:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFrVmU9C8WuASHmFCN4OehwduC+37BrqqgzW2xLFh4Rq3IcRcwek0AQ9PGHb4tJ14xKYNM
X-Received: by 2002:a62:75d8:: with SMTP id q207mr8684130pfc.35.1557326686116;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326686; cv=none;
        d=google.com; s=arc-20160816;
        b=IaIHuIGThlJOu5vxgpVPCmJB4blFX9nridLILPEhAx5ANCOOPbwnJPUv1DyM6FI6kg
         +hlNhctkzckGzQEk1lUGziqgFuSERHe1/AxecRVd5dfv9Sus1IDn5POBJKUnYaNvrCcP
         2s5vf6aNl7Zo1PfIaTnOi6hbHe7WzcGI+QcPvBRDhJP60XfvN6lbKlaPgbOemQscurQ+
         RWAT3gNpBHdIfbQejaFmEJa/qAv3OgPQFp9rYYI7DJFDrc45l8rtsp7f+TRn8r5are97
         AERB5N750lt1Fk9F3VcKaOVj/md2/uVRNxYLmRM7GiZylN8hFO8y1BJuLyJ1KQoKPU1v
         UAsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tOzY6YSnq7kQhl1Xfuc6nOLOEJG32H3j/0J5lRyZG10=;
        b=Mg6wl/jrZG7jMUW6Wlf85EKUAVQzPTYXzhbti1L6zfwKw4/vWa90hKrwR7wU5dl9Nh
         Y6TNUohtZvjd45FU89bw++0s91feXKkMfD32c2yM2a3zCzSIzI9QQdtiiogEqUISyNSg
         6038mvKb+h6Uf+aYLJWwUPVUv8umuEjkiGvyR2cTb9/Ov8X/jO9oQtq9wttjn5+gSxYk
         xKemfrgsaALr78pVy8scDeUEX5Cyj/xxjuQLORKEk8Gm0VxCEg+NbfQWYcV49hssaUWa
         so5+ZTa0RsEPMY7IMSpQZBUTOpnML79yZCAzP+/0GC/EetM2j9hlmhmEs/pnW/qz4uIu
         Y3TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 184si24250871pfg.32.2019.05.08.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:46 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga005.jf.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 36B88B36; Wed,  8 May 2019 17:44:30 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 31/62] keys/mktme: Require CAP_SYS_RESOURCE capability for MKTME keys
Date: Wed,  8 May 2019 17:43:51 +0300
Message-Id: <20190508144422.13171-32-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

The MKTME key type uses capabilities to restrict the allocation
of keys to privileged users. CAP_SYS_RESOURCE is required, but
the broader capability of CAP_SYS_ADMIN is accepted.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 496b5c1b7461..4b2d3dc1843a 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -2,6 +2,7 @@
 
 /* Documentation/x86/mktme_keys.rst */
 
+#include <linux/cred.h>
 #include <linux/cpu.h>
 #include <linux/init.h>
 #include <linux/key.h>
@@ -393,6 +394,9 @@ int mktme_preparse_payload(struct key_preparsed_payload *prep)
 	char *options;
 	int ret;
 
+	if (!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
 	if (datalen <= 0 || datalen > 1024 || !prep->data)
 		return -EINVAL;
 
-- 
2.20.1

