Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6595C282CF
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D6282184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D6282184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A6A28E000A; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BC848E000B; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 135998E000C; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC13C8E000A
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id i124so12724307pgc.2
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=zkYOBKDkCPssvs3YCV5eJaPkZC0ctM/7YsEXK+Vqdbc=;
        b=CCb1qXMxyTyl6zBqkpEEmjiYo4iYtW3QOvFEGdqmaM0kk3dYnN1wa+USGK/3B2PXY8
         CNlvSJQufTgvoNvpED3AO8kW4ph1KvCXqcurvlnDfDboTRS+ZRTlpIC9Etrr63xDW7fF
         yHZMUZIsnpvjbcJQB0Gzixi74tLcvt/U+TAbSP2oXyxqxyplkQmmcaGgjM7jprrlQaVv
         j2R+/OYROQavrVqniwG7MHPTQa2YUBeQGxov6h+puBTfIRQW6g3JKQSyqgfbruqWFdQH
         8aa1+u9HJ7Tcr5BulGQ7OKyEjQDOMTVDJ7sleDhAsLd2Xz5NRThrQ38+d5obv5IOB1Bf
         Qynw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukc7c7Cm5nVt9dFyQh7af792xauOvKYOHmkmEoVXcb+pd8WDZgS/
	HuBuxKvxZCcMO4KVSa1SJs6CZnlsMuXC4VQSeYO8uBYJ/5znaQxL/pasQuPzZAn31yHhSxhd2CX
	JEHPyBKN9gdeCTXLpm01vVUDQOjfRaavrEg5qQ7IUKU6rmf0RS3v+633KzKEy6LiWkw==
X-Received: by 2002:a17:902:6948:: with SMTP id k8mr23500667plt.2.1548722354367;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7OjLVAb4RNNRV/Wd68Y59voUQ/HDAkgVEm3CFxZHJJrvTnITDAaCqt2Ep40+Lk4orFhTUF
X-Received: by 2002:a17:902:6948:: with SMTP id k8mr23500597plt.2.1548722353037;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=ZsTky7MfSxqt8yGie4VcTem4atDhtGkdgAyKexUFFD5SFmSOZZdBnNSUtuAV877oZD
         Mq8Xe5w2Zm1u6hvrsNixRGy0tpxxw2/nF/EmunTqc6MNA1/RthS12FsefJWj5CmiVVzo
         gqXasINC3bObE2+1n+8DyESq4Bbzun2rpjsbxLf7G3opa5W17cQzDIewpqrj58UPnmUk
         SpsyCOeVABLSRcegc10mdcOOoSahwXve2J4FfQ2SkQ2bKC6VhW9amBoh/PHkni1p+X8q
         Lctdg9AQ54LCXdpmkCizf+a+KWC8ylJuO60/Tn75VgRh84Gtlo6cbbdTze9zP3Gx+6Gd
         463g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=zkYOBKDkCPssvs3YCV5eJaPkZC0ctM/7YsEXK+Vqdbc=;
        b=PUt/uX4p462OW8X/eAEg3iMFxWxR7fcObclJ3XVGqWKchpff8sQBy00yCi1WP4BbKr
         bkiajBuZlvhvWx9FoWBWAIFegco6UQxEUPiIcNADXylQXk/J3kjDuWw3rAdH5mZQ3nZW
         FlwUQeyNYC2iIIIwkmoevKNkz1unkzN9bDoDirNg9BK3FGmGXFTayXG23r+td5qYcRTx
         uzo9nq0EU4tXq8d4w5M+BIjUjvZvgBzFy7aUd0eWcvCIN/Rag5gRcfb4a+naaHPO8CSc
         3f7/lRrkXIzIFE8hLHD9nIDHq7uL04O9cB21kJhVgGq4yskI4AuVzKe5RUzRsgrCUCZ4
         whNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i9si7660357plb.35.2019.01.28.16.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921915"
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
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 11/20] x86/jump-label: remove support for custom poker
Date: Mon, 28 Jan 2019 16:34:13 -0800
Message-Id: <20190129003422.9328-12-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

There are only two types of poking: early and breakpoint based. The use
of a function pointer to perform poking complicates the code and is
probably inefficient due to the use of indirect branches.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/jump_label.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/jump_label.c b/arch/x86/kernel/jump_label.c
index e36cfec0f35e..427facef8aff 100644
--- a/arch/x86/kernel/jump_label.c
+++ b/arch/x86/kernel/jump_label.c
@@ -37,7 +37,6 @@ static void bug_at(unsigned char *ip, int line)
 
 static void __ref __jump_label_transform(struct jump_entry *entry,
 					 enum jump_label_type type,
-					 void *(*poker)(void *, const void *, size_t),
 					 int init)
 {
 	union jump_code_union jmp;
@@ -50,14 +49,6 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 	jmp.offset = jump_entry_target(entry) -
 		     (jump_entry_code(entry) + JUMP_LABEL_NOP_SIZE);
 
-	/*
-	 * As long as we're UP and not yet marked RO, we can use
-	 * text_poke_early; SYSTEM_BOOTING guarantees both, as we switch to
-	 * SYSTEM_SCHEDULING before going either.
-	 */
-	if (system_state == SYSTEM_BOOTING)
-		poker = text_poke_early;
-
 	if (type == JUMP_LABEL_JMP) {
 		if (init) {
 			expect = default_nop; line = __LINE__;
@@ -80,16 +71,17 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 		bug_at((void *)jump_entry_code(entry), line);
 
 	/*
-	 * Make text_poke_bp() a default fallback poker.
+	 * As long as we're UP and not yet marked RO, we can use
+	 * text_poke_early; SYSTEM_BOOTING guarantees both, as we switch to
+	 * SYSTEM_SCHEDULING before going either.
 	 *
 	 * At the time the change is being done, just ignore whether we
 	 * are doing nop -> jump or jump -> nop transition, and assume
 	 * always nop being the 'currently valid' instruction
-	 *
 	 */
-	if (poker) {
-		(*poker)((void *)jump_entry_code(entry), code,
-			 JUMP_LABEL_NOP_SIZE);
+	if (init || system_state == SYSTEM_BOOTING) {
+		text_poke_early((void *)jump_entry_code(entry), code,
+				JUMP_LABEL_NOP_SIZE);
 		return;
 	}
 
@@ -101,7 +93,7 @@ void arch_jump_label_transform(struct jump_entry *entry,
 			       enum jump_label_type type)
 {
 	mutex_lock(&text_mutex);
-	__jump_label_transform(entry, type, NULL, 0);
+	__jump_label_transform(entry, type, 0);
 	mutex_unlock(&text_mutex);
 }
 
@@ -131,5 +123,5 @@ __init_or_module void arch_jump_label_transform_static(struct jump_entry *entry,
 			jlstate = JL_STATE_NO_UPDATE;
 	}
 	if (jlstate == JL_STATE_UPDATE)
-		__jump_label_transform(entry, type, text_poke_early, 1);
+		__jump_label_transform(entry, type, 1);
 }
-- 
2.17.1

