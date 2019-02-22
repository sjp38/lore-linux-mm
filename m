Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D43C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2E952070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mN2rwWcX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2E952070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4798F8E00EA; Fri, 22 Feb 2019 07:53:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4048B8E00D4; Fri, 22 Feb 2019 07:53:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233548E00EA; Fri, 22 Feb 2019 07:53:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCB9A8E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:33 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e18so961806wrw.10
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Cci7ZilHiWLbA64Mc6AMOu/bLCyx/LwY/bSfReud1WI=;
        b=lw6VOv8AH3zhHuBo24fiKCzdf3asevK0HfIYwPBgxv153GivQXHw9G0HLKRgKuPGDy
         VOZot3wXpaEIG5Lt8zwv+RamFn95TkDoJUOmg5PjF6weR47w+d/WmD07OFuRFElaq0Dw
         wW3Y1f+3Q1CXf6tnOV5E4qkGTYBiswi5iyjx/cfOg09PxmAnqZaGWMSxrBhikyGmOwro
         xG1Vn1rtewbIQivRHSj5qZtnr09RlL9uFj+lmRPiOOuuoBfPvxPcRRcUxpgiJDXG37KX
         qeXNi7Nuc92Tc01X4VSRNqknswHWT5/6vIKL14bZfJHlja7Zto7Sdaa8PVMaUAAWU+Zd
         841g==
X-Gm-Message-State: AHQUAubvH4P/prd+TrO0Mzgy1nWDKajDT6zKlkM3dRGJERWbyRAuufX+
	y2ID8nF/6bsIX9ebOz4va2U/2+Rd8QucGBEvpIKy0zD+r1CG0bZQe21PMI/4iOEnbXAQfnVtouj
	iywDsxCWIGErKtuAYSd1GwJgR4kdnm2dh3B9zIx//vMsgoGyttgZT+aflomWf18mMw2TDvljcMc
	KwdmecabhIJwf16h2HkFYqq/pE5YIR4jKlvpkDBnbwy7uxaz9HUCWm55gDd35Q2la7nx7Xioaop
	3iWIiZPcsE6PFsPd+7SiQHDZ3fK2dLz0EcDODii1U1MTZHwnb4HXurq1u5CpHxLjpXRlBMhZh3G
	688dvF/idTKOrzAnTdMHXN3DrBPrdIgFaQo1bN2TMtpecV/KGx3VbJXM5V8f72ayqqnQFDHKX7A
	Z
X-Received: by 2002:adf:e58f:: with SMTP id l15mr2071353wrm.309.1550840013317;
        Fri, 22 Feb 2019 04:53:33 -0800 (PST)
X-Received: by 2002:adf:e58f:: with SMTP id l15mr2071301wrm.309.1550840012321;
        Fri, 22 Feb 2019 04:53:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840012; cv=none;
        d=google.com; s=arc-20160816;
        b=nTjXHoABwavalTZoVy7+MvHBDwAt9v2MPBY79YiO1JjcQs+hROYxta+pjvA8Mj/XA1
         qmVUcJ0AKcXdWp4m8XsgxCgLnS3nBcJrUiTositxPUP/Iaw8zT8KCBBl4FkzrSKtGpa7
         0HqsB/TKdxYVSlEb+4Udf7ver2NVQ1BtNF6MtS1IMKh2hHxSvs5cNsvRAD2jCLn7CYp/
         IfF57uFtoKD4rhaUDrXdpHXo/l2dtulryEwWOA095d4JWCcyxq5kwKc+wrDrzl0wTwpb
         3NlyZiJB7oAuzRAmq7Z2chVkU22PjdPCoO8IGCg7VKZkeYJmEj4wWqI83zJM4PXtlpsm
         KZGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Cci7ZilHiWLbA64Mc6AMOu/bLCyx/LwY/bSfReud1WI=;
        b=HOKEGhYaWUsyr5D9U/UHU/1OFYFzWcXPnMMLPXciHhZ5y00dBsAWutjwxhMKkiAn3n
         2Q1xKApXtC9660aHJ2Iu/0y8KzcFxuoFSuZqCtZXkeHaEKbT3BPwcL13LQ4GjW8io48A
         V7fr56Uz5a7WaA/44MftrM+l2txvq5fWjBu4LSvmakKGHnISTLd+lLR/ZGjC0OiZb/Lt
         I3VXmeIz0jKKJZ/VYVmvOT4hZCz2cC0SRzuQBz9rcI/tIp0Iwt9UPAs7WPsUo8ckh/ot
         o1wSQ84fiTPMuV8NWWiZVbUiA2/aFJnlxyE4acEX71ldXSJf39b6cGcxlpHv3RX2MKL9
         xGsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mN2rwWcX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18sor1097784wrn.45.2019.02.22.04.53.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:32 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mN2rwWcX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Cci7ZilHiWLbA64Mc6AMOu/bLCyx/LwY/bSfReud1WI=;
        b=mN2rwWcXbmXv4T54C8g+dQZceONkqeqfDnfFBkdS/1z2f+11756LZtilFVL9vmN8Ub
         asXmJYdmjDVQkCK9dtCydjOWxr+KWTUU0EEaMipiA+1WfFsqs10CUXUyp5B+yuljcBc1
         0C0tywzNl+KEsDi5E1V9a1Ws2dGSyCYbuw6oXbdAfIH3UZ7l6SUpfEF4GcTbMbPCNeeB
         Ot4+ZahceUY35FVe2YDPYC6Ax0ARG1yKOQgJNw51FBiolm56hh/XyUho+qccTDZViTri
         rRytDOGFcggeSEQD/tMlfRQXS2V8i4wpp47+jYCO3tkhuGYSljzEFFfYn0oW2evDAak3
         2ugw==
X-Google-Smtp-Source: AHgI3IYNE5YTD6dA2Rm0c87bwvFj8qPgC6wZI8wCmOm2tGxzmyo49L1MzMubdg2VCbScaD+W4rhlpw==
X-Received: by 2002:adf:f6ca:: with SMTP id y10mr2869999wrp.148.1550840011806;
        Fri, 22 Feb 2019 04:53:31 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:30 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 01/12] uaccess: add untagged_addr definition for other arches
Date: Fri, 22 Feb 2019 13:53:13 +0100
Message-Id: <2b5a5d7d7a36a75a2a796f0c2b9b30669d81d470.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/memory.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/memory.h b/include/linux/memory.h
index a6ddefc60517..fc383bc39ab8 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -21,6 +21,10 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
 
 struct memory_block {
-- 
2.21.0.rc0.258.g878e2cd30e-goog

