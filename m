Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34E2BC282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2AAA21841
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2AAA21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B32A48E0009; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 818208E000E; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A37C8E0006; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E14EC8E0006
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so12656765pgb.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Vw4Tc9/qTce/ps387hTBEGuO1Y4CjbTaT+4DjGZJWvU=;
        b=T5boXAyUMQEKpbIXOvfNnyOC884jzm7P9k8qm/vwSIriGX82anwDDkI556hviD7z3w
         GnfzLE1bxdEhBxzoBfB4JENPl/B84ouUKbGWMN3yCaq0pbX6QyzI1PxVdG53DUO1MQsB
         r8pNYAiAOF2kOZHo5Qf6YT/lMk82lQx8Za4+CuYe+GfMQRYoU6D4KNau9O9v9znpqQow
         GSbpL9T1A7u81rbzBN0NBj2ohht30Ph/VxSPDD6f+VqCtyMxGqm54+REEvRQGDIi9f/t
         8RrhBBu7N1vEVR+yQ+XeTVSQWNitMdUF3NakzNSfrXukyEpcOmZpvjFARyfFmve4K9JH
         0L+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke9q+5Pgx+QDTXT21kE+iW5XxzUuXCCVF6ESRpLzU8SrqChaI4y
	yw1cIu7JXQ0zWLbhKaGIJ4EPdxagCQVDlMuTwWKWph0pIFE6+WrUElk3dfEyn9VVZbqfOz7IwQs
	K+jtYMyq4l5DtaJLCmLbLm2YXYmoDHK2VSmHnF2Um+HCaoEgfqV7BpnVezkcTeD1TLQ==
X-Received: by 2002:a17:902:bd46:: with SMTP id b6mr23794256plx.231.1548722354605;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7HcAIhcAgWkYG36PqXjWXi9LhFTeeznhI4+kjWdpIyeohcwpZTzf0EUwlxh27kmjdDeOYV
X-Received: by 2002:a17:902:bd46:: with SMTP id b6mr23794223plx.231.1548722353858;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=eG5MIpsKDRmUbEb4wVEEhZE0EoG5HF7w4Odc6WZuwqJD5JPi5hw49HL/DrHJT5bI7p
         HbOThegSC+wVRlsQpVUw1KJoTo0gmHyIasvxfZdISk51PVG9AQDqiYliahuoEDCgM2NO
         cbkcDaJTqyOPkWwRzrWsa1+z0k0rZVUrxVvS060Z/Zj6xuu/OM1kPdPTtcWL1FJknwfI
         jMyMIDQv3h+hHh6qTOALL4DCfNQO0woewfMHroyYX7KrxD4UrU9Rx29lDjPQXV/Glx6V
         b6l5bu+7hzlvfiecULUs1PXXnQ617n4gHPOUk4/n+zrONwBG6AyL23UWWPQV6b94YnzX
         ZcrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Vw4Tc9/qTce/ps387hTBEGuO1Y4CjbTaT+4DjGZJWvU=;
        b=dCJv8KXd4wEBvk0l1qdtnFVO5DCtmbWz/VqbH+m4HDGEUZcTSrSU2PTt5M6F2IQIFq
         LqysW+gvU1mdq47OIj+2yZaiDNOzc7l79Sp3CvoDm8iGsjPxrQkiLFCbzMg2p/9CcXT/
         trlH0IH/q5pmmb9NRAdjM9TCaACX0TWdFJlPIu9kAqQSGji2cYSFul/wmBsYhYfZNvdF
         7XGm1qyxBWPBNMOIxG/SGD2YfD07UHnAcOwth7e8uc5iAdd3/8rjntyivg4hS7jOAIho
         sBvEL9VPkVFO7iBinN6I56bc6df86wze9OTmBfbwBv6Od+5e6yDvN77ePwXNEpivB07G
         M20Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s17si4514712pgi.513.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
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
   d="scan'208";a="133921906"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:11 -0800
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
	Steven Rostedt <rostedt@goodmis.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 08/20] x86/ftrace: set trampoline pages as executable
Date: Mon, 28 Jan 2019 16:34:10 -0800
Message-Id: <20190129003422.9328-9-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Since alloc_module() will not set the pages as executable soon, we need
to do so for ftrace trampoline pages after they are allocated.

For the time being, we do not change ftrace to use the text_poke()
interface. As a result, ftrace breaks still breaks W^X.

Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 8257a59704ae..13c8249b197f 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -742,6 +742,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	unsigned long end_offset;
 	unsigned long op_offset;
 	unsigned long offset;
+	unsigned long npages;
 	unsigned long size;
 	unsigned long retq;
 	unsigned long *ptr;
@@ -774,6 +775,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 		return 0;
 
 	*tramp_size = size + RET_SIZE + sizeof(void *);
+	npages = DIV_ROUND_UP(*tramp_size, PAGE_SIZE);
 
 	/* Copy ftrace_caller onto the trampoline memory */
 	ret = probe_kernel_read(trampoline, (void *)start_offset, size);
@@ -818,6 +820,12 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	/*
+	 * Module allocation needs to be completed by making the page
+	 * executable. The page is still writable, which is a security hazard,
+	 * but anyhow ftrace breaks W^X completely.
+	 */
+	set_memory_x((unsigned long)trampoline, npages);
 	return (unsigned long)trampoline;
 fail:
 	tramp_free(trampoline, *tramp_size);
-- 
2.17.1

