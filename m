Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8071C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 702C3206A3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 702C3206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1873B6B027A; Mon, 22 Apr 2019 15:00:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15DFB6B027C; Mon, 22 Apr 2019 15:00:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04D1D6B027D; Mon, 22 Apr 2019 15:00:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDE446B027A
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so8450626pge.16
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wig8MszCtUvg2yw20GAeD+70ac75PEX/7kXXzCB+iko=;
        b=cuY6OGIdKniqQzmIGwbcQDR1//vTQnDRlKKF293nFwy3TuIra9fQ8cEU1vWGkUF0I8
         TcQstcTktaAAx9w8Bw2sV8tYvod3WjuFc30UtW8QPdmnY2Ttgi4POlWg5ByUWKleDcns
         qD+GFp6EdR71EN8kAptw03X2bCihVhJKWjgHp4G2fNzbknx8u0YA68yEDYnfuS9hP6iH
         HomedUVE2MnLOUoUfSawwzQ4HWzcTxj6kxtq6E0VLMmcrhuMaZhvd8OZaEK0j47+KAV9
         in8x+y9H9uFQyRVgNTXOmQ/FQpXhXhnAimTr3/LQ4bOvefFuhjOv2zBqtmvnkRC7coGW
         XfdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXGTdxtxPeejXL+B82YvVPLAD7sdPMxQsh0GqBp0T8bDUscoEwn
	8+qaXVG685Xsml8V1gNc2ElT8dDpuyeZAkViy2Pg6DF56vGdsZxC5/9/TuK1X2wOr7KOtwHpAtr
	Xwl3Wh5ajgO6XNS+hY/Q8fVhDVT1WJbAggbR/KCbu2wEWeK33V3Q7hbO95Qxo9/RsRg==
X-Received: by 2002:aa7:8289:: with SMTP id s9mr22141075pfm.208.1555959612443;
        Mon, 22 Apr 2019 12:00:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvV0GCTjO37DMsOGs/KK8hCp8tSVa+HJj1Dd0DIso1ckmD4yvuMq9YHf2BJFoMxsAlvLGA
X-Received: by 2002:aa7:8289:: with SMTP id s9mr22134794pfm.208.1555959524147;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=CQWZV2KNeTMSl2u+qs1IvlJQ1pOeupxhS5YoOkjQWTDoZbZ1/majz6uFUlqb8fp8vb
         EaNk3p+DD7JDMupHevE9ksBKtRyhtaAV5zyeKUVBq0DTLIOG17XiP4/8T/eJ2uQvu2z7
         lv+We4pn+sLF/iN23eVZbRuGQd2N7ueQKpM9P2w7FZLR4NJA+d428B+hoBxYd9FBWZ5J
         PG1XvGnoy/iHCm5Aw2ipU7T5SDi4qDctZGSRegsNzTYP8/KVEHcxCB+l7INaXT9hM/iJ
         1Yhqu+PI3uEGUtuZBE121O0lFmUbW3ztoc/lAnn1xSdUYBNtmMLFJvqZTgxZeAauyd0k
         y9Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wig8MszCtUvg2yw20GAeD+70ac75PEX/7kXXzCB+iko=;
        b=uuSN1X10nQYd1fYUJXt0iYiIyPHCczIs2dgQJMUjhOqCzB3QmDuCMUt7dKUMoWmkI7
         eQzIMdKKCTrKJrz/rDGQdrvJQqt8FeHq4dL3EjW62r4EtE9Dtt68Trbrz0ZMmyppVjkl
         95oBPbJ4JlGC6E+Hu5TYZy3vViYKMNy1HrOA51QNSh4QiVrA87B/pWnbv/eZ+IKGN+ke
         zUT2ealmUHN3VxCix/UW07nmQ7KdZU347afs5n673cmhCF1+bKqmrSzkbF54FQhoLVWF
         PEc2RG54gGtGMnpqwTFJEDjjd9k7qr5Eiyw1RbJH6G49mfs1g4N8M9g1IYqeoDOOz527
         ugXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417170"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:42 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
Subject: [PATCH v4 18/23] bpf: Use vmalloc special flag
Date: Mon, 22 Apr 2019 11:58:00 -0700
Message-Id: <20190422185805.1169-19-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set RW
before freeing which is no longer needed. Don't track if the memory is RO
anymore because it is now tracked in vmalloc.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/filter.h | 17 +++--------------
 kernel/bpf/core.c      |  1 -
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 14ec3bdad9a9..7d3abde3f183 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/set_memory.h>
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <net/sch_generic.h>
 
@@ -503,7 +504,6 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1,	/* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -733,27 +733,17 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	fp->undo_set_mem = 1;
+	set_vm_flush_reset_perms(fp);
 	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
-static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
-{
-	if (fp->undo_set_mem)
-		set_memory_rw((unsigned long)fp, fp->pages);
-}
-
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
+	set_vm_flush_reset_perms(hdr);
 	set_memory_ro((unsigned long)hdr, hdr->pages);
 	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
-static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
-{
-	set_memory_rw((unsigned long)hdr, hdr->pages);
-}
-
 static inline struct bpf_binary_header *
 bpf_jit_binary_hdr(const struct bpf_prog *fp)
 {
@@ -789,7 +779,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
-	bpf_prog_unlock_ro(fp);
 	__bpf_prog_free(fp);
 }
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index ff09d32a8a1b..c605397c79f0 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -848,7 +848,6 @@ void __weak bpf_jit_free(struct bpf_prog *fp)
 	if (fp->jited) {
 		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
 
-		bpf_jit_binary_unlock_ro(hdr);
 		bpf_jit_binary_free(hdr);
 
 		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
-- 
2.17.1

