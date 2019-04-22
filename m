Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 318B4C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAAFB218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAAFB218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99D7E6B028A; Mon, 22 Apr 2019 15:00:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94B376B028C; Mon, 22 Apr 2019 15:00:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8633E6B028D; Mon, 22 Apr 2019 15:00:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCE06B028A
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m9so4027596pge.7
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Mq726et3FUsm8L5SG93p+KUhd7ShOgthVM8qUN29ytY=;
        b=tsVgT7d+AwarlsAZ8YIzHSO6sB8Ofsi/bDgekv99XcZRHTf2HSsoIFRhAVoxFNkJ0i
         NGRhg1mIPWtrbeiKHgTtw92YG5vaSH2yEGSl39tDEbyZQotZi3Jnf17CpC31abHKq/Wu
         CQkKUolKtWwEA/5nLs19mXn5fqfLz4OVlhYxrEGhgwacJjLJU9EmF1oV2Pf8X8QQ46GB
         3EmB21sN/spJQVejTi4xN/upmm5VY67ii/vJ48ZrMKb4SEdCeu54tvVadHnfjJ02BpHU
         88j8D66AzxW8FWiWKcpjEZvHtUx85Z7q/vQTB1OWUk4uFP1yTwdr3wj+1jLARYhzSXEG
         B4hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW0hM5G2Q9oY3SG0fToH/Yse+xvgqNJzaSj3WgDSTsDu2Oclqrm
	jkJUHYAswCmVUf0mM0IM29hG+TequN+9GVbcHoTP2isAmco0cdutwW0OogsIR1jg9y1wwvH4M4N
	tAho0zbGaMr9g65oUX3/bIJAQjEBctNimsJxItL+D31CqrK1q7iv1W6CXuHMxv/W95w==
X-Received: by 2002:aa7:9ae9:: with SMTP id y9mr15824728pfp.111.1555959647985;
        Mon, 22 Apr 2019 12:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzpDPDN71sXTXpfhpNUytktmHFKk/Zckmevj3IodAYa0Q1E7aP1ypO2iREiAgzlitSCPcj
X-Received: by 2002:aa7:9ae9:: with SMTP id y9mr15814097pfp.111.1555959524408;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=sn9syfbaUUlSKdLmsf26iJP7asdZ3BrUb0G8oa8XDkwBwXX3UJQ2jIT5Z8b89I4CpI
         BZhkSdptpAr0ARUO7Zv5kNVgHDPu6gvP5EAdN9swV8NUD1I3LAojPea1K+NI/wjbedZ3
         +lsahbJoStDjXAWpcM1+lTOYafFwfT4ql1IMHJMCE6NSi6vDKEgglBQRddvFc01JLEeR
         ZkN3ukVMZAwysiyo71Lij0U1+w5MUoGIb6WAjfgBAZc5VxCvaezpEHaDs6GUvf8x08cA
         5bx15nAFKaRkhWhGwLS2PZuDoyIJkJbLh1MQK29o5fPVZnyjpl1jdx/NgfqOR32EMsta
         d5hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Mq726et3FUsm8L5SG93p+KUhd7ShOgthVM8qUN29ytY=;
        b=Eof6E8dhYOityICyufq45gPCEWJVJkbPikHiVgA0yx5iC1WTE4tkgycrNB4CxxzDaW
         LGFAwdGMd434UyaTWuJmr4yrrjscto2WUC/w2C724wijYYRXCPrfGFGn712tbCiAPT5d
         gzXgP4R6WTEKjrYnh6HE0o0DEC2X5k3I9oRnbfSA3bgR66B+ogkpMjnYjZXH2qR5diZA
         J8REDOHDSMgA9W5MRBrk4wZTCU/5EZdhwEXicpSMlU9gASjHiyVoqnQaitWKKlyWC6mj
         n9Ttq/ueIxcNZk7HcepwSXmHEbEddiZX8HWAXbS6PIGYj+uOkEgeqaq+myGJqO7BfLVi
         hTTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.44
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
   d="scan'208";a="136417179"
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
	Nadav Amit <namit@vmware.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 21/23] x86/alternative: Comment about module removal races
Date: Mon, 22 Apr 2019 11:58:03 -0700
Message-Id: <20190422185805.1169-22-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
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
index 18f959975ea0..7b9b49dfc05a 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -810,6 +810,11 @@ static void *__text_poke(void *addr, const void *opcode, size_t len)
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

