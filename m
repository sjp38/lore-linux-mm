Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B5FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90ADF20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90ADF20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA47B8E00CF; Thu, 21 Feb 2019 18:51:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7FCE8E00CD; Thu, 21 Feb 2019 18:51:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF4FF8E00CF; Thu, 21 Feb 2019 18:51:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC3E8E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:05 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id z1so310456pln.11
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=g3nO4xFM3yb0X+OIqTEtEp6LbffMj61RqStKCNeSSiM=;
        b=qc74dj2/rpjaBZkFInegxLpCxx0xwQUBjOsZPGs+vreArroybHmRQl2MChKYU2RHnG
         Y8I8lHtawJAFkKbC/A0hoOdinKgjaiTEHNG1XeDpE0MWxuWUFiuxXInWbahIrrG4tGYQ
         11KZPlQ19tXVoan33VI4zOHYeRjEnC0whfxkflER9RWp8SaIC1yDbXLDZW4UGO/I7Zv5
         I7t5F6NfGwZkQHygCflZtZTxjFBdKouXj481httBqD9UYg8gFU+jaue/obrWPAf/Y5xI
         UJs1XJmvUGG2CPvPrxop86kaa7q05N5zkLzSjo8Xuw4Mo6j/7xMZYaZIGOzYs9jnfAey
         LPLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubKru3RhpeIf28FfrYGmmoQffGZTazXFyB4qLjBW0fJQb4e+re5
	hyZiBMtUHQe05waD3LxMjTau4nWVAY4HoqTK5orx0gZg+tCoJJlhRuWCvSeQDzYFXVB+jk+IUfL
	xlftb/ThVhbztWVQMu2iyAdiaQQMUKE72RCsOUl2Y4rA1gVpqYkU8lva+wVQ08L5QAA==
X-Received: by 2002:a62:1706:: with SMTP id 6mr1159670pfx.28.1550793065191;
        Thu, 21 Feb 2019 15:51:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZCAJe8wv9av38zzUAyLBCZF+ONqaV9cES9443A74+6g0x6M3sLe6DiIDyx/3gL2H00lzwK
X-Received: by 2002:a62:1706:: with SMTP id 6mr1159630pfx.28.1550793064314;
        Thu, 21 Feb 2019 15:51:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793064; cv=none;
        d=google.com; s=arc-20160816;
        b=H41EPtIrkcZnimSVk+Yh+PI/kn0Eo1QuDDN+9oiZYm5SNLtqUDRWoe3XRpc1vSHoAK
         /I4WqCROyiGpZR/rAUohJOIXGyj8mMxQFj34+UpE5FjVPyeGe49vYNSZXU/TIiXjbn8I
         LUFF75ainLzeZ2OFuaCNzPppQCrOHcChM9HGy4Wlg3YD2nvDKSaaTo6oGNIWAe7Ida0m
         ajpv5l/RAprBKkLbFuPhmO60Tm8Kf8s+sZ72oOgLCFeFO32nT/+mmgs17UZ5bU14K6n9
         MD7VltI9lP1y2L3pKYC66tFYpNU1wuB3zY36uDoIv9kKFkMVs/6ApXUScSOjWey7u4i1
         L2VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=g3nO4xFM3yb0X+OIqTEtEp6LbffMj61RqStKCNeSSiM=;
        b=y+XoCBuIevFusM2JCkc0dIM0akiKMaIvTFjVXp6BaXNsishs8IvX1xC80SNNZBo2un
         4jIIdIAVhJrJWGVfdOsM4SCoDMPvfP2/GEjfPUwq1+EYLH0ay3czCs61Aqnyzy1uMgvY
         cRYIEiv7G5ewCC6zOKnOrIFsOyoPa2fv7e4h583tKqvJ4JXgrkU1x/HPwymxKTbjXqlv
         uv0Q8Lj+9dfpBS+zHF53t1RyYEChI1oT/xQdU25sLzsDmNXTy9PPKdL0SlLgF4MK+lKc
         qKNYpvLpu3O394LJE/HC+YtjJWJ5OH5YlUBSFPT/jbzisry6j0o6Czyr4G232CNZ0KRF
         OTSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:04 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:03 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394918"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:02 -0800
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
Subject: [PATCH v3 11/20] x86/jump-label: Remove support for custom poker
Date: Thu, 21 Feb 2019 15:44:42 -0800
Message-Id: <20190221234451.17632-12-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
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
 arch/x86/kernel/jump_label.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/jump_label.c b/arch/x86/kernel/jump_label.c
index e7d8c636b228..e631c358f7f4 100644
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
-	 * As long as only a single processor is running and the code is still
-	 * not marked as RO, text_poke_early() can be used; Checking that
-	 * system_state is SYSTEM_BOOTING guarantees it.
-	 */
-	if (system_state == SYSTEM_BOOTING)
-		poker = text_poke_early;
-
 	if (type == JUMP_LABEL_JMP) {
 		if (init) {
 			expect = default_nop; line = __LINE__;
@@ -80,16 +71,19 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 		bug_at((void *)jump_entry_code(entry), line);
 
 	/*
-	 * Make text_poke_bp() a default fallback poker.
+	 * As long as only a single processor is running and the code is still
+	 * not marked as RO, text_poke_early() can be used; Checking that
+	 * system_state is SYSTEM_BOOTING guarantees it. It will be set to
+	 * SYSTEM_SCHEDULING before other cores are awaken and before the
+	 * code is write-protected.
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
 
@@ -101,7 +95,7 @@ void arch_jump_label_transform(struct jump_entry *entry,
 			       enum jump_label_type type)
 {
 	mutex_lock(&text_mutex);
-	__jump_label_transform(entry, type, NULL, 0);
+	__jump_label_transform(entry, type, 0);
 	mutex_unlock(&text_mutex);
 }
 
@@ -131,5 +125,5 @@ __init_or_module void arch_jump_label_transform_static(struct jump_entry *entry,
 			jlstate = JL_STATE_NO_UPDATE;
 	}
 	if (jlstate == JL_STATE_UPDATE)
-		__jump_label_transform(entry, type, text_poke_early, 1);
+		__jump_label_transform(entry, type, 1);
 }
-- 
2.17.1

