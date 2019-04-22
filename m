Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 885D4C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44D63206A3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44D63206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57FA96B0284; Mon, 22 Apr 2019 15:00:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52F126B0285; Mon, 22 Apr 2019 15:00:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 334E06B0287; Mon, 22 Apr 2019 15:00:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB2B16B0284
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:30 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a17so3811622plm.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3ZPWotgC+OZrWZLU7OmIKSzSgOEFrjgXAzYtiypTDWI=;
        b=PgYDNLsV7e3jVLtszwkwqylou5h3IAqnKTleAO0GMMXjlEB7KVeqMsqKkslvdmMz8r
         QxBTLbT98EtrVVX1DeE5M1WZesbbm2XNcUXhtInyvOc6v2ql1hla4c/Lws1V0Zh4qyv8
         o9jI972VlUadapzw9OKu66wpL+GeIkzrYsgFqFDnzb2itLn7KpR1qfYlnhRE9eqBtN2K
         h5ABrPc60BsZwRJpFBY0DvLL5ApjzyU+gIf46FWVKdcI1TDXDYTjxNoFVqpUqXKgFxYu
         TUAjHvbSfrrs/v00T6mjpTfz27Nt+6K9nThRqyA/CpiGR2bpGuXyhQgLhsOKZLCTum/U
         lHBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXuQYPDkiKfA9wvINPldtYByXEOYEt4vjkTYPisiWQ+PklxXj9S
	5D1NZeY8vmvhN9WSHdeqFvjk9vn59DHIT0S59T0j9uhaIfGm2RU3voY0Y/RzvcLFmD+8zy5c6W3
	GvSEwterd+FTl1E0K+982b4zOM4WIRMxk/yLHyVtF/FOMaoQbZEtriTMdxLH5xFwJSA==
X-Received: by 2002:a63:5405:: with SMTP id i5mr20178301pgb.212.1555959630586;
        Mon, 22 Apr 2019 12:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGge6BqRIG0ADGr7plZgYlLlIEBQn5O65n0EXpw7MBRu95GgyDSExtk86GxQJQJBSX4s2U
X-Received: by 2002:a63:5405:: with SMTP id i5mr20171045pgb.212.1555959524343;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=iKebrQewscfEtcjMUVbTnBY0yFZShuk3shsRu87VGjSToXSban4FhVBmpIo3T8HDeO
         /HS0TyDr1tmXLshlHv6zTgKojwXKgo0qB15xbJaq9aBOgvlWUZMzsZp2/3hj3Cg3pAJl
         0g/5YHEfKMVDRAQPyIUqFn2tGXngdIy6XvB9j9cnjFiXt7gCmMFze1lcBGRkbjR8FvTT
         t1fyKheVQKbdGimQjOI3eFeeAf4bfAX2Y6J6TXxFhXa1dmrMkCryf1BVcSApTiRDDYfw
         /ujFT4wOb3jDd8ZkgS+WHA7w0MiauIHMguMEuIi4razG1+Mlc5IjO8FuJdlFYWGYCBzU
         JEWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3ZPWotgC+OZrWZLU7OmIKSzSgOEFrjgXAzYtiypTDWI=;
        b=hfsvLIZ+hT0hMIS2U6X+MJL9M5awYEGlSUbzQXA5xK+JAcftd/cwQJM6e7THRdzCo/
         TVHc2QRpaygFUgM/JoWQydneJGDwLwGBroyUuEqY6e1Xxvgerr+xNRjO26imkAl+n1rD
         a49+gtZGP3mxiuN1LAoHquKWS+Zu/2buNvV5O62wAkv7IQaPLye49pSHarje2joNtlhi
         Si1o9wQb157YSfjX6edJeZ5AZYLGZ0Wm/eyOA7wzn/jD+qjk6dqnfVtA623zD9oEoY8R
         AusJLm6QxqSFGj9TBnhEbnvE6iPup93Anb6AoPpDH/WhPhPCzuF/zrd7IrR+jHGeaqtp
         4g7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.44
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
   d="scan'208";a="136417173"
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
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v4 19/23] x86/ftrace: Use vmalloc special flag
Date: Mon, 22 Apr 2019 11:58:01 -0700
Message-Id: <20190422185805.1169-20-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Cc: Steven Rostedt <rostedt@goodmis.org>
Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 53ba1aa3a01f..0caf8122d680 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -678,12 +678,8 @@ static inline void *alloc_tramp(unsigned long size)
 {
 	return module_alloc(size);
 }
-static inline void tramp_free(void *tramp, int size)
+static inline void tramp_free(void *tramp)
 {
-	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-	set_memory_nx((unsigned long)tramp, npages);
-	set_memory_rw((unsigned long)tramp, npages);
 	module_memfree(tramp);
 }
 #else
@@ -692,7 +688,7 @@ static inline void *alloc_tramp(unsigned long size)
 {
 	return NULL;
 }
-static inline void tramp_free(void *tramp, int size) { }
+static inline void tramp_free(void *tramp) { }
 #endif
 
 /* Defined as markers to the end of the ftrace default trampolines */
@@ -808,6 +804,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	set_vm_flush_reset_perms(trampoline);
+
 	/*
 	 * Module allocation needs to be completed by making the page
 	 * executable. The page is still writable, which is a security hazard,
@@ -816,7 +814,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	set_memory_x((unsigned long)trampoline, npages);
 	return (unsigned long)trampoline;
 fail:
-	tramp_free(trampoline, *tramp_size);
+	tramp_free(trampoline);
 	return 0;
 }
 
@@ -947,7 +945,7 @@ void arch_ftrace_trampoline_free(struct ftrace_ops *ops)
 	if (!ops || !(ops->flags & FTRACE_OPS_FL_ALLOC_TRAMP))
 		return;
 
-	tramp_free((void *)ops->trampoline, ops->trampoline_size);
+	tramp_free((void *)ops->trampoline);
 	ops->trampoline = 0;
 }
 
-- 
2.17.1

