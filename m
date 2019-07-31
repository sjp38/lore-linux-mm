Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2672C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACBF5208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="IOKuLaqn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACBF5208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E00D8E003E; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CC028E003B; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0827A8E003D; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 903F08E003B
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so42606428edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4nUUGiekxDXyLHELJNk1/crPjGXFhQCWsxTcExxSHys=;
        b=J50sPXb6tYsT5r+ttNWDkHpzcl2zeG6p727NHGFI553LoM/p8z1xSHamHQO3PImw9x
         T4Ib3vSKgm4LqO994eyuq6kNHYrrPZTcoVA7pUm+VRqcaoRvfll3bnMwHqXRJ3k2Q+6L
         G3bSLc3c5S9/tQ4hQBE0NScWkdSGHRa5o9ctnTgLcD5hQxfmeKFQBm5AcVLvTsXXtSYv
         VNkoGAQJsAp2fQaTAwZiMfiMcRfOjfgexchYBkzUhKX8ON/4Vw2wqwBQGsmS7142PJFt
         NcvYwE3X0QrRCIJ2zpaNaoWgVpSBzUTcXWVRZTSskJYzc3lZwbLNxIfu+wvHD2KCH7w6
         rD1A==
X-Gm-Message-State: APjAAAURUIsK2SHbO7Pz7ssTTYn1OMbiE2jSv1tjjfYAEQrV7WMW7fuE
	YIP95b7ZDa0cwPxEhLuBsz46pdLPj9N3crcZxBvvCeYwlw4sq+YMcacqpuWw60aCQA+hnLxje6U
	bF+I3aS6qxh3GI0x9yNcobBEaCbtIASsRQqRbhNxMr/d05w+PQay6DT93lU5JVUI=
X-Received: by 2002:a17:906:4694:: with SMTP id a20mr96567156ejr.67.1564586631149;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
X-Received: by 2002:a17:906:4694:: with SMTP id a20mr96567061ejr.67.1564586629865;
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586629; cv=none;
        d=google.com; s=arc-20160816;
        b=qcjXOM5Y4HR5q8EsFHMLyqFhEHLOWUKY/PXOWqPYmFqsBOr4Fs/m3Mk61AfD1FWgE1
         TtgmABRb13gy57C9l4OTnW8q/RM7lsMsMUwpE1n9APqE1ZEP1S54qqK0DJpWjN/4K9lL
         pgfFuYBWOEGWdJsk5PNM9OHk06wlS4dA0cTUrpWBUVCgHjyhw49XlWSDCsSWVSMw9LdM
         5FvsAzcFXeIAv1aaUSbrDn6/yUzc6TyGcsFjNCsI+30H8AUdAGwntj1tV1T6tbPBCdYC
         dMFpXfRlJ0wBAEkVO2WdCJceSWfJcwTU3eWtxAxaXkqwmu4wh4CO1P+kZJTb50aEcMNh
         hGyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4nUUGiekxDXyLHELJNk1/crPjGXFhQCWsxTcExxSHys=;
        b=YZRZ8dxha07X/ZP7rZ4SDoFQEzjCOBFRswAMy865Umi1/bgLKCrgNChEfUYRXBgLuT
         uE4Mg+JA8DboTDxs7oNtrCZ0/6d7zQkQsMKVcInPVQITp3bPMXmcvSP8LAtTOj2sqzf9
         fzfQQCMOWSUvyDyvcoSlzCTpKkw/BMI3Pvme7rYjBHTKSQV4yuQSDiF3SO/f0UJxqBAl
         LGjpXyLJ8KMOyblDAKa2+NE90F8SY0q6z2kExgHVlN94MWeGs30y3sRqUIGQtrwUTsGU
         8t07fN4I6jNjVf/ZChvBc4ICbrsdnACssizQ9l+8p/CuzhVVrUOIBcKqTyZjBYViaRm1
         ksjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=IOKuLaqn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck15sor22693715ejb.58.2019.07.31.08.23.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=IOKuLaqn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4nUUGiekxDXyLHELJNk1/crPjGXFhQCWsxTcExxSHys=;
        b=IOKuLaqnLIIvDxh8sGiA5Ti1EgZD/pb+tvmY2A/5Qcpvrnrj/8Q6+39fm9WysKchIW
         hxGKfQI/tErC99xqo32YRJXMLxuXvw7D5FxRJcrBpR8LO7tBGljabTEW8R9zvaZ7Gtu/
         5JhEe4A5G3i8YpbuhOwyBAKNi3WqHjxlhczPzXXfzxS1YgpNI6CrX/YkA/t7pf+O56zg
         jZvbsgItFZICFlQrj2qkMS9K0sSkOv6pJAFh7XH0Y/DNZ6ULvgHOHCZfkaErZTNsmjQb
         h2tqUsjMeDmKdo4PyoPbBB79hWABkWEqSQS6tHXaEaeEcq0q3LGFncuHeCOpiPphT7io
         M6bA==
X-Google-Smtp-Source: APXvYqyocU9LaLEieM1frl2MdSDXaIV0gvyho3ioPkKIqAAuamyJHGIwJo2jc8AHxo4CrQ5fTnM4cQ==
X-Received: by 2002:a17:906:9711:: with SMTP id k17mr96659095ejx.298.1564586629507;
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id 9sm8073168ejw.63.2019.07.31.08.23.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id CD18F1044A7; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 32/59] keys/mktme: Clear the key programming from the MKTME hardware
Date: Wed, 31 Jul 2019 18:07:46 +0300
Message-Id: <20190731150813.26289-33-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Send a request to the MKTME hardware to clear a previously
programmed key. This will be used when userspace keys are
destroyed and the key slot is no longer in use. No longer
in use means that the reference has been released, and its
usage count has returned to zero.

This clear command is not offered as an option to userspace,
since the key service can execute it automatically, and at
the right time, safely.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 18cb57be5193..1e2afcce7d85 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -72,6 +72,9 @@ int mktme_keyid_from_key(struct key *key)
 	return 0;
 }
 
+static void mktme_clear_hardware_keyid(struct work_struct *work);
+static DECLARE_WORK(mktme_clear_work, mktme_clear_hardware_keyid);
+
 struct percpu_ref *encrypt_count;
 void mktme_percpu_ref_release(struct percpu_ref *ref)
 {
@@ -88,8 +91,9 @@ void mktme_percpu_ref_release(struct percpu_ref *ref)
 	}
 	percpu_ref_exit(ref);
 	spin_lock_irqsave(&mktme_lock, flags);
-	mktme_release_keyid(keyid);
+	mktme_map[keyid].state = KEYID_REF_RELEASED;
 	spin_unlock_irqrestore(&mktme_lock, flags);
+	schedule_work(&mktme_clear_work);
 }
 
 enum mktme_opt_id {
@@ -213,6 +217,27 @@ static int mktme_program_keyid(int keyid, u32 payload)
 	return ret;
 }
 
+static void mktme_clear_hardware_keyid(struct work_struct *work)
+{
+	u32 clear_payload = MKTME_KEYID_CLEAR_KEY;
+	unsigned long flags;
+	int keyid, ret;
+
+	for (keyid = 1; keyid <= mktme_nr_keyids(); keyid++) {
+		if (mktme_map[keyid].state != KEYID_REF_RELEASED)
+			continue;
+
+		ret = mktme_program_keyid(keyid, clear_payload);
+		if (ret != MKTME_PROG_SUCCESS)
+			pr_debug("mktme: clear key failed [%s]\n",
+				 mktme_error[ret].msg);
+
+		spin_lock_irqsave(&mktme_lock, flags);
+		mktme_release_keyid(keyid);
+		spin_unlock_irqrestore(&mktme_lock, flags);
+	}
+}
+
 /* Key Service Method called when a Userspace Key is garbage collected. */
 static void mktme_destroy_key(struct key *key)
 {
-- 
2.21.0

