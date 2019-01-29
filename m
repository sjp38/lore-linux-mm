Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE8F0C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9696821841
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9696821841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 678C98E000C; Mon, 28 Jan 2019 19:39:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D1B18E0011; Mon, 28 Jan 2019 19:39:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04B7C8E000B; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95D708E0010
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r13so12656792pgb.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3s8AOXI4GMnsmXm4fbD4VoH1iGqOMdZAYRD6Y7Z/6yo=;
        b=AVkKcQJtsSFQ7jIjjPXBPnv4cEqldmSdvazsu+ZbkgGj76IwCxQEXdGymKBLgLncaG
         CIpP86JUkiv3t0xKNre6po/vCiiA6+e4XJIrLwZQ6cOhrrKIE1JHasGzsz8DMx4Ewifd
         JzTelswnK2dkefP5YnYneEb1T7F93kQ2538nWM6mwfVveR4csQbwfSEiTSx6QenBHoGP
         QzbZA/ZrEa1WmEA7G9/I+TSDsrtt0S78BGF+WL1v3ejj12FVHdu9r5AzQGhqbv7yKVvb
         lRqAK1cdeC39Z1XZkJ+9jBeVpIzanZVHOLSOzkZz5MIHaq1MEOnGtvqUwbqksrChFo/J
         xoiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukelQ5VQ37voQh3oQAzWEYGPuLN5tPgYcWjoWzetLpTKFjjXhkv/
	ailB9PX7lDQPANubg23UqdJMiGneVfk36XYp3ssTqCa+pHpUpqOX5piFLNL5iuFzSSHeHEjgOQc
	fbW3JhIbn4NiyfwL/wTRvU2+1tDf1y/bxWrw53CFCaVNjxWr81H7BEpbWzSQh5v5K/Q==
X-Received: by 2002:a17:902:7044:: with SMTP id h4mr23639545plt.35.1548722355296;
        Mon, 28 Jan 2019 16:39:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4VQaVfarOk3iHxe8ebQTkQ1mYFWSENUZBDAJQV341v7VDKecjOSfJYZKZ/1RtvMsiNF0DA
X-Received: by 2002:a17:902:7044:: with SMTP id h4mr23639495plt.35.1548722354417;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722354; cv=none;
        d=google.com; s=arc-20160816;
        b=ETeYuZaKBY1oy9xPlG/MrZTQXy+J1tY+EyoBdu3AJ9PbizHVrj3SsmjPjX7CY3QuUd
         gQz9VmDMIarwqQUPmIRtKwmU1ppVsqe90+cvPmhiwk4iImP46kp755dL+bXpmiMoUmlr
         ZfLOD+OF+B+JHTvgkOK42Ilek8Uw65oAAwevDSV0KtxRAX/wSJ5yRBYOh5i+JhlOLHyt
         zp6iE+5tTe3u+TcCpzmLgYHlL6SvilUnG34PyMlCnWgy4g52XnNiweMA8ySOSl7XKf+X
         Zk3Ukc4Jz4FC4qUtCytf0t/7z2lP/Sf6pD7eN8hAQql5RhX3DzrFnT5l2KxiyCYqNZwf
         fdxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3s8AOXI4GMnsmXm4fbD4VoH1iGqOMdZAYRD6Y7Z/6yo=;
        b=HSSP4jbcHK4pkISG3L/hCR9zL+wT3Z/5uxFwOqPk5ZnDNJcV7d79kbxruHI+elxS8t
         +oVMgL+hlP7XEFOvyMtyKz9M8/mUcQO3UqSHKFZbMULEwzW5WjJN+cjiir8F1d4oOoS4
         RZGQmN+8gTIBOOLQ76WOaNL2wpAoi9p2HK5VXpUDKd6ojtejptijcz93av8xfsR4LCbt
         bzMyw8eaYDAdk9N/lrTeU7xMlWZASWtY9sCFkuUz6gtxOwZKOD/0J6fuyKPTMWf5O9xx
         9bLfTNbHU06pVpNkxnChnLob7sr2QTEPnuPT9FP3QHwfrT5VPTERNDCCWgWQz+/oabBH
         1AzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s17si4514712pgi.513.2019.01.28.16.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921945"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 20/20] x86/alternative: comment about module removal races
Date: Mon, 28 Jan 2019 16:34:22 -0800
Message-Id: <20190129003422.9328-21-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Add a comment to clarify that users of text_poke() must ensure that
no races with module removal take place.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 81876e3ef3fd..cc3b6222857a 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -807,6 +807,11 @@ static void *__text_poke(void *addr, const void *opcode, size_t len)
  * It means the size must be writable atomically and the address must be aligned
  * in a way that permits an atomic write. It also makes sure we fit on a single
  * page.
+ *
+ * Note that the caller must ensure that if the modified code is part of a
+ * module, the module would not be removed during poking. This can be achieved
+ * by registering a module notifier, and ordering module removal and patching
+ * trough a mutex.
  */
 void *text_poke(void *addr, const void *opcode, size_t len)
 {
-- 
2.17.1

