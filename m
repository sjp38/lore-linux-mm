Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 871AEC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CCC220B1F
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CCC220B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 121846B028B; Thu,  6 Jun 2019 16:15:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00EE56B028D; Thu,  6 Jun 2019 16:15:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D781D6B028C; Thu,  6 Jun 2019 16:15:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCF96B028D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e69so2309820pgc.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=7Czs0GMtnAfWbMOpCmbFxFl+kPT2QpCRlQ81FhMsGEA=;
        b=Jk0CvmUvUsyki87BSoZ9QKnYqjhP+wbmqPvud2kfBRwJ21dsxTLzyfS7m173x6Y7HU
         u1yRcd0SxF3OWqEdBUWfL1zLdjb9WbD30sG/BRxL+K4IBchltaw6qiBArK9ncrjLbiy7
         4wfOP2sihCS/qnTdKxRy1+LTfHCjQG6LetBOOfOPgg80+0+9dkJZ27oP3+EYVEfXb4nd
         eyT5WaAAtZxVyo2+0qnrL5MZdKaOsQFyQLeRjH9rr6JmXliYcE7hFWPSNfsUfMzZieNA
         1qLylxltk9hIFZVx+akDjG523rLifgUBHltvlIM+e2IFFsVCvEs9Msok/mIWzgqXGPLj
         zcTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWDGOUulgrqQXhn6eGwy1JSYNpwfgtAqYw1eilyXf6eu64ZgaRC
	zx0oT52Da906ZTM0Ca3Hcs8H5odWAM+3dNcFJ16o1YV8uuo4oEcCK6xakRDOJguoo0N7rhQDp/c
	7enfykTziqgucLIajqcyLgzgzAlaEsxPQDD7SuwS9Ap+4v0uhH28lHHiJCxJPj3NTCg==
X-Received: by 2002:a63:470e:: with SMTP id u14mr293078pga.135.1559852112230;
        Thu, 06 Jun 2019 13:15:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcVfqNEWfs16llEt+Qkpid/2+bzUeI1Xs4iP5oRpR0uNjo64Me3bTcfGGs807wnnWpulFq
X-Received: by 2002:a63:470e:: with SMTP id u14mr293025pga.135.1559852111426;
        Thu, 06 Jun 2019 13:15:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852111; cv=none;
        d=google.com; s=arc-20160816;
        b=Hhj6cSkylh7bJFU/FAZlUK10VOrJKoEH2Rv+IT731ByH2yC/T+KrH9dfP2ECNzX6Af
         z/gMq3g5lzOGhvmxVa8BqVi5+tbWncbw9p/Gct4KMmJf+GFe+v69KDhkosuP65NjDQqq
         U662JjbSp16FzC0ugw/GGo05NV+ghwVRG//CigKC7uK4cLNpYTEYPbYkcA4hsJx5rvkC
         KWxC/Q9Jiuyhb39dqb+WncsWyzkCb266RHd5ga2WJTUuhin34qyXCqH9W14/ZKEfytrk
         nFpuSxBQ9lJ0cjUHBsEQOQYk6DBbmMHKLVXcpeDTMivEQjIJRbGcBZaZs6sfHTZUMDWH
         lN8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=7Czs0GMtnAfWbMOpCmbFxFl+kPT2QpCRlQ81FhMsGEA=;
        b=XVsCzIOQB4XrSDxDO6zO6HLYlVYCMlbviCkVV9RwlHHKByx+yAW6l7FRMU2Wni1sSN
         IOgvNFeECk1OyJbWoo1TXz4h64mUhkZo0BjfrAqWZjAsNV7UHrNmos9g4SW00M2QiRgd
         8QaK5meq9o+a71bvSBM/FGonF6gdpQWpsZnCtB2JWW4ghVqqan977Z7WqumOArs7FNw2
         8aBbb95tmWT4+uBJCeuIy2sUVAt4z9IOp5o9CmH5tg+S4rnfhIXHLSxWgFW2e+RYZhff
         GhS4lC9isLH9abRpBgeT0M2ap+Luy8OwIw6wlqUdLmiMOTBCk2rBsp+ltW8lvKMnAm8z
         R/Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91si31377plh.398.2019.06.06.13.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:11 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:09 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 02/27] x86/cpufeatures: Add CET CPU feature flags for Control-flow Enforcement Technology (CET)
Date: Thu,  6 Jun 2019 13:06:21 -0700
Message-Id: <20190606200646.3951-3-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add CPU feature flags for Control-flow Enforcement Technology (CET).

CPUID.(EAX=7,ECX=0):ECX[bit 7] Shadow stack
CPUID.(EAX=7,ECX=0):EDX[bit 20] Indirect branch tracking

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/include/asm/cpufeatures.h | 2 ++
 arch/x86/kernel/cpu/cpuid-deps.c   | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 75f27ee2c263..21b2d9497c0f 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -323,6 +323,7 @@
 #define X86_FEATURE_PKU			(16*32+ 3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE		(16*32+ 4) /* OS Protection Keys Enable */
 #define X86_FEATURE_AVX512_VBMI2	(16*32+ 6) /* Additional AVX512 Vector Bit Manipulation Instructions */
+#define X86_FEATURE_SHSTK		(16*32+ 7) /* Shadow Stack */
 #define X86_FEATURE_GFNI		(16*32+ 8) /* Galois Field New Instructions */
 #define X86_FEATURE_VAES		(16*32+ 9) /* Vector AES */
 #define X86_FEATURE_VPCLMULQDQ		(16*32+10) /* Carry-Less Multiplication Double Quadword */
@@ -347,6 +348,7 @@
 #define X86_FEATURE_MD_CLEAR		(18*32+10) /* VERW clears CPU buffers */
 #define X86_FEATURE_TSX_FORCE_ABORT	(18*32+13) /* "" TSX_FORCE_ABORT */
 #define X86_FEATURE_PCONFIG		(18*32+18) /* Intel PCONFIG */
+#define X86_FEATURE_IBT			(18*32+20) /* Indirect Branch Tracking */
 #define X86_FEATURE_SPEC_CTRL		(18*32+26) /* "" Speculation Control (IBRS + IBPB) */
 #define X86_FEATURE_INTEL_STIBP		(18*32+27) /* "" Single Thread Indirect Branch Predictors */
 #define X86_FEATURE_FLUSH_L1D		(18*32+28) /* Flush L1D cache */
diff --git a/arch/x86/kernel/cpu/cpuid-deps.c b/arch/x86/kernel/cpu/cpuid-deps.c
index 2c0bd38a44ab..68ef07175062 100644
--- a/arch/x86/kernel/cpu/cpuid-deps.c
+++ b/arch/x86/kernel/cpu/cpuid-deps.c
@@ -59,6 +59,8 @@ static const struct cpuid_dep cpuid_deps[] = {
 	{ X86_FEATURE_AVX512_4VNNIW,	X86_FEATURE_AVX512F   },
 	{ X86_FEATURE_AVX512_4FMAPS,	X86_FEATURE_AVX512F   },
 	{ X86_FEATURE_AVX512_VPOPCNTDQ, X86_FEATURE_AVX512F   },
+	{ X86_FEATURE_SHSTK,		X86_FEATURE_XSAVES    },
+	{ X86_FEATURE_IBT,		X86_FEATURE_XSAVES    },
 	{}
 };
 
-- 
2.17.1

