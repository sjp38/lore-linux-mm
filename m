Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3896C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B616206A3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B616206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 383176B027C; Mon, 22 Apr 2019 15:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 331656B027E; Mon, 22 Apr 2019 15:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F8F96B027F; Mon, 22 Apr 2019 15:00:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D93406B027C
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so8111191pfn.8
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=TdxUBqKvjD04gvlVW2fqTrr9rgpG7ttN99ifXgy4wJ0=;
        b=LA7FUm0Bf7Ix8i1chPcq7KDAmrTG+LZLC6aPWNmEbR9ffwJ7ki04ATCBq2sAS6g8Fr
         L/aMOi49/r6HXXNYxVoMxsoyAkcKeQTJUQ+psT41RMAS09dlPGQ0XiZe6sO83aClrd9n
         chXC6Q0W6gtWMdlceI3Jbd4bZ4AMNMSw64z3b6cQ91OlfjHN32whtdKy7daNb+9p8J7U
         +ljrf5ATFxDP1n1ZK8tkqoIzFOQn22UiP5HE6vk437ZZYlaT7YJSS9NmoXwVXWPVN8WN
         SGvIg7NjJmcpTzVmCPgv36rL6/lCp+mpirFdm/sd2Dz6q9r/X4cbd7l561wi+FwJXIuR
         sYYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAURAXeRQXiLdYylK9HLtfhzWNXtFuvlxRCuD39E56XvjcB39Bs3
	hjfs1pxhLZchWKM2uVTEweHlS1wJDIpGvEY+WSqryddQccD301mE2XBUE5sNdqNExGB8414PZlA
	UqMuOMjrLdaOvoLRoV4uJlcB11CpdU3tzqWF9CAlYdn5Mxyoigv6gUL6zjMOzPWu0tQ==
X-Received: by 2002:a62:8381:: with SMTP id h123mr21594925pfe.226.1555959618536;
        Mon, 22 Apr 2019 12:00:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybgitSf8nYF6r0XiOi/2fRNRM2IGuVliv4NY+Q5+zGy7K3LBH9EkBSpr9zPEez3ZNC9V9s
X-Received: by 2002:a62:8381:: with SMTP id h123mr21588233pfe.226.1555959524629;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=otacb2kMBFuYAx0qKOlXG6dqFKXmQ40HYoxiSNu+GNIui+FArlK1qoRMRfwZhxEjiY
         6ULRtWdBGQ2jdX/CsywUdUN+y+YieGP5fR7Hr9+dAoH6yO2JfsPLpdGzpYwu20H7vm3h
         t3Zf3VwH730QLeXKi2fbQbx/xPEav8oZwAvu+0VhOOEt9bZMMFMD3c72D163TV8IsvXW
         p7djFiXzTvhWFFsqOhKh6NKl+Ybdj18njA67XIQRTcfEN9PoqneEXXOnA7Ja72Y/DPHp
         SusoC1+U2iALlKBAbZXk/bvw7oAKGyPc5ApCnxskvppLviBttfHet71K7BxwnPFjT1Ip
         r+3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=TdxUBqKvjD04gvlVW2fqTrr9rgpG7ttN99ifXgy4wJ0=;
        b=wgTOUpq3gX+dbLIEPzPceNdAL5xfp4mS8BWmYXKNmZHV5yG+EC/wmlxQvhLonKg5U6
         nOLq/va5483IL/CU+zfTPci+H11Fwju1X7TujN+oaYbWk85J5eh31EokvjV0PoI9sjOH
         xDRBwzjOuTGPvKDVKToA4AbxKBzFQdl8FutCbvnmUVRUY/IEFy0HE/20G6CNRm83XdOJ
         GEHkUT4+YMu6wsCCXrNJ8lhFIx9/pj/Y8uNsY9a/SUYg2GXfAFov+1Xg3CiBSbLHRlxJ
         Y1Mz7r6gCutrEvWCDlQvwOZuueGeip+aNLHoxIrntYHoDuGnzuVbj7byd+2aNGbTWUC0
         6d1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w15si615875pga.591.2019.04.22.11.58.44
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
   d="scan'208";a="136417185"
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
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 23/23] bpf: Fail bpf_probe_write_user() while mm is switched
Date: Mon, 22 Apr 2019 11:58:05 -0700
Message-Id: <20190422185805.1169-24-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

When using a temporary mm, bpf_probe_write_user() should not be able to
write to user memory, since user memory addresses may be used to map
kernel memory.  Detect these cases and fail bpf_probe_write_user() in
such cases.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Reported-by: Jann Horn <jannh@google.com>
Suggested-by: Jann Horn <jannh@google.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 kernel/trace/bpf_trace.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index d64c00afceb5..94b0e37d90ef 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -14,6 +14,8 @@
 #include <linux/syscalls.h>
 #include <linux/error-injection.h>
 
+#include <asm/tlb.h>
+
 #include "trace_probe.h"
 #include "trace.h"
 
@@ -163,6 +165,10 @@ BPF_CALL_3(bpf_probe_write_user, void *, unsafe_ptr, const void *, src,
 	 * access_ok() should prevent writing to non-user memory, but in
 	 * some situations (nommu, temporary switch, etc) access_ok() does
 	 * not provide enough validation, hence the check on KERNEL_DS.
+	 *
+	 * nmi_uaccess_okay() ensures the probe is not run in an interim
+	 * state, when the task or mm are switched. This is specifically
+	 * required to prevent the use of temporary mm.
 	 */
 
 	if (unlikely(in_interrupt() ||
@@ -170,6 +176,8 @@ BPF_CALL_3(bpf_probe_write_user, void *, unsafe_ptr, const void *, src,
 		return -EPERM;
 	if (unlikely(uaccess_kernel()))
 		return -EPERM;
+	if (unlikely(!nmi_uaccess_okay()))
+		return -EPERM;
 	if (!access_ok(unsafe_ptr, size))
 		return -EPERM;
 
-- 
2.17.1

