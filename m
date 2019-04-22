Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 058A7C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B27DC2064A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B27DC2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B72EE6B026E; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86A606B0270; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 695C86B0272; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 074AD6B026F
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b12so8132071pfj.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=yNv4uuWY37+QDIo+8eJ5Cs1RQKFygWuhu/mUpTFc+50=;
        b=sOmvkPM0hjPLNVKbD/nO4NRCPqU+sRwrgTYx2nW/zeoeu0HabIFSTKjAJOr9AMz1We
         8Hm4mPkKu/aqw6vT0uhP/u2Nt4z+Bc8GmHgprkzFffJIzUlyahwX4TUMth7MV+pg8xkN
         Elzvv9UaHoTIPvXx0clm/Z6CL2PVj+nT9ya/K1ytKd6OVdO80tbqK94klEucfopuMuR+
         DEJ5/9qMEyqMqNCR+l/c2SMBBLiWv1A4fjlxZIllKsxagnfPtAEoi49zr8siRr7SKNvS
         Tuelp6JqCPzDApW5HxgfIQYXCesbnO6nuqAnmLPa2HdoySSwdEEd/c2JBo9fVAxM2kSy
         PEpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXSou8xQ8bgdD/A4/dwPWcfOXr9uOrOgIEtDSDcSnjVZ9NsHVvJ
	4puaoTu5mru1UbkDA4w2Eb/Rl1vcYmiYiNnjs5o4sda14f/222mjuMiLQ38rCmzAvktFfkCfVSC
	kiKeU+xOU5kf5QsoRPDX29CPPnY/6Kk8jmYQQ35XDf4FoS2AIRZciVnzxjk5EAFpUFg==
X-Received: by 2002:a62:6086:: with SMTP id u128mr22585385pfb.148.1555959534698;
        Mon, 22 Apr 2019 11:58:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtJvIHxx/i2Ts3cNM7XFD4I1LfROwkoBTclyOfRewUUm2q1+kxow7IgGo9jgKt5ObsRqsq
X-Received: by 2002:a62:6086:: with SMTP id u128mr22584615pfb.148.1555959523584;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=H/KOPbNa2iOWnGgMDAJAGdvUb4n3FIrNRJfMsqjIKrHgM3l6QKG0Rbc6rgU71z+nTo
         HZhMygM3y/hJHYgi1mEmHbpxT91Mgjvn77jjKgnTPWsc+UVzL1J2N5ZD/1EMJ9zQkcBr
         CrLrUGuD5Wl08hu7+uPKi0nzO/KcT4wk7d+Xna/ZzvPxxyI981SFi2xW7NzQlFF44sAa
         gS03Bd1NNdNFYumpJsROlpG/Ygk4iNNaIl/55yLBiL7RmPRYt/+6+FAebVbGGCjZhXwm
         Gb6VHhw57DW1pFEZzlUJfeMFmxdp/d4LZVIqWfMbIgxWaHkdICt11sQ4BEG49hsLoZvX
         L/pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=yNv4uuWY37+QDIo+8eJ5Cs1RQKFygWuhu/mUpTFc+50=;
        b=cHuuHOArXWDvlW+OPQqp13NMQgTzrTQtk/vX9uJ2Dc8xeOZNt3WI/gFkeDVE/+TkMM
         spBQDtKrh6M3wJBTKYGcu/cHiOgk7+S5kcqgoECg5bgwEO0Hp0cyoORFBjYSnyjXro0m
         cyKyXOgjOliOP9dBlTE3iVQelaZQFCEezO4ze9Nfm8wY90YRYN28NjZ8B43PZqLCJV/w
         KwfI+ritT10UzobF7cLFSeGUF5NaBQpRuW2kNph8at+6gwguj6cNGYiNp39XHFNsE396
         YuBcQsMCUMWqM8AIDtGMf9EBL6vldXrp1EYlmbPI3wXjqHDMmK46l7XfpB4jbmkj0nAe
         K5fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417146"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
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
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 10/23] x86/kprobes: Set instruction page as executable
Date: Mon, 22 Apr 2019 11:57:52 -0700
Message-Id: <20190422185805.1169-11-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Set the page as executable after allocation.  This patch is a
preparatory patch for a following patch that makes module allocated
pages non-executable.

While at it, do some small cleanup of what appears to be unnecessary
masking.

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index a034cb808e7e..1591852d3ac4 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -431,8 +431,20 @@ void *alloc_insn_page(void)
 	void *page;
 
 	page = module_alloc(PAGE_SIZE);
-	if (page)
-		set_memory_ro((unsigned long)page & PAGE_MASK, 1);
+	if (!page)
+		return NULL;
+
+	/*
+	 * First make the page read-only, and only then make it executable to
+	 * prevent it from being W+X in between.
+	 */
+	set_memory_ro((unsigned long)page, 1);
+
+	/*
+	 * TODO: Once additional kernel code protection mechanisms are set, ensure
+	 * that the page was not maliciously altered and it is still zeroed.
+	 */
+	set_memory_x((unsigned long)page, 1);
 
 	return page;
 }
@@ -440,8 +452,12 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	set_memory_nx((unsigned long)page & PAGE_MASK, 1);
-	set_memory_rw((unsigned long)page & PAGE_MASK, 1);
+	/*
+	 * First make the page non-executable, and only then make it writable to
+	 * prevent it from being W+X in between.
+	 */
+	set_memory_nx((unsigned long)page, 1);
+	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

