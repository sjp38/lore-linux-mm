Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252A0C004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C54D8216FD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:28:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="qZGVbx1y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C54D8216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BFF26B0008; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25EA86B000C; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 101126B000A; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEB586B0005
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:27:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n10so6779643pgg.11
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:27:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1PJA3Yin4hoCvAbgpNQ3y3XPaY8D40/vCFSTYD5zapQ=;
        b=JyKjLiKeEG61az49ecuwO3oN9BtLKXqdcusLSRFMSbr95lTKhLv2Zh+EMNzBCbguRy
         Lmuqgom1dI6ECJSpjxJHqH7DcjGGIufbAjoPbmennZuPX55Qsp6TalEJmVbmME92bKjf
         V2gm5tJp7F9ifPeUf4eCrS8mjZVNYWqjOvYN8AxDgsI1RjZDxp4hKt9g44zXU5A4FWBh
         FMtKty4Fg8mo3JpugeffN4udDyysMdGhbH08iGz8e7wYOIzCnE9qFpcSC4SBOPUArCjH
         dbTw10/UFYtLbhkUCi7USvBHjpdRl9kxtCYF2pJ62UQqdNRfZNeMh5qWV1TxaGn9fRCB
         nVdQ==
X-Gm-Message-State: APjAAAUmwSG9wVT3hMT0Qz5KUU4nI+HnAUh49QlbVZX7UM+eii3gl2iR
	LOybYbZ91QLzlQt4SPveP6Fr68rwSc/8KNk8KaoTf9RBhQbRkJWB41/E0jSg6eNuTj2cDaPkQVK
	NrVl4RYaK9LVZ2Ijr4scjfSuKiN5foAuWfD25ewV3Ak65xd/lmjSMVoRC16WX6Poo1g==
X-Received: by 2002:a63:a1a:: with SMTP id 26mr3493877pgk.11.1556573278478;
        Mon, 29 Apr 2019 14:27:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+Ld4xi3LV0lNQyZpJX4XFhSSzyfTOaAKMmejnrdRqTsw9A3fnMKgPFrehCs0Id3jIF/su
X-Received: by 2002:a63:a1a:: with SMTP id 26mr3493793pgk.11.1556573277195;
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556573277; cv=none;
        d=google.com; s=arc-20160816;
        b=CvAsqKDpSDrWBMEVwJBWHcno/vcoQ5hm+uKXiNKDFAgHJfRrD+X1A1zJJQqloICPkN
         fQG1GzBjaqMax62sB1z9J8HQYbMODvyugDKiZ9w28zcIBj5j8oFjagsoQHhVjKFwJQP/
         djhyoRbDcY6cMU4cOIguxNwKMMILPOAhwHqcKT+Z8q4z2L2TtWONpQkhqDVLnP5697ML
         oOxcaVn/bzfD43LnnjGlzFzUyNv4r4yxQrS9GdI8VcnWe6SK40IR+IzNgzlNIrU17wzw
         Rx28xCXq6LsbbzBk+JpKLmD48FN+cfSkxUwhCwF/Volqq505B9slg3gzSEnGWVKo8kPz
         VmBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=1PJA3Yin4hoCvAbgpNQ3y3XPaY8D40/vCFSTYD5zapQ=;
        b=f0i8xZXPQVnlUd2BEAIhEBvAEBuXVB4gDkTmH4rZ1dMUc8c5C19e+fwHmFvWBan8G5
         lJ3BVdDz7kNK/sG4yyej4MRf7Ds3qnChN5vBocyEWcNxtdlfwySWkyz6Tc/fQwYzuUUS
         PapYmC/Td94zZPYaqe58sd0SD3Gc47SZnL80J+eWuUMFOvibmC2mlCZgpnNbjB8o3CGz
         G7f9kbegy26Y7+fPBnxpwbsXywht7tyg3yftCURjO0uYf23yrkSc9GXluhglBzU7394x
         Y2vJFnMAtguKXZROHbbOMElB33ylU86n7u5ofWsm1b4ev7pzvnoy52Xm3rYL6WZfIjFU
         70hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=qZGVbx1y;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id r77si23694774pgr.140.2019.04.29.14.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=qZGVbx1y;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556573277; x=1588109277;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=tR6tu/boLUZjadiHISW1+7oshhH05ZDXJ3aIDITiz8w=;
  b=qZGVbx1y0m393wyg0dulkSBMxRCscN7zgPcK50Chm+cDMRIBQGUGViGj
   sKuDtmZko8EIiGJVmmkzE46Z7NNzoYJWW4jJO1w0CZrNgXWrFs07qMPah
   EgOZBb4+bX8/0E+jAaKejYmp0OVyFFx8UVs/g4zqp4xFl1PjmVmwmX09l
   XN5YiTcQhHI2zlHwBki0dV1mlMWybFQ08r20zmKYwjVabiSeUxIwMyn24
   Sy48fl3ZkhAXFQgJYkHt2uWLK+qZDo8b0QLrbCfKJCHdaqqUc40+3hg1u
   4//66jULOASuLf9FTmnbpK5q+rgZ/it+ScbC1w8gUKFf4AvmnZxf2jGzd
   g==;
X-IronPort-AV: E=Sophos;i="5.60,411,1549900800"; 
   d="scan'208";a="112062155"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 05:27:56 +0800
IronPort-SDR: 0U7Zu9IEumiglRDzjknAlCXE3Y653GFHkFMRgEByzN0kTGJYowfHODFSGWZMWjt7MYF9BBJlp+
 EgGyXDCppllZXvG8v+f9pTY0jq74KaLTxDaeGl0UetIe2958RxWdH7y6mG0UW0NDN9214f2bkM
 2f7RliPTmWDdPfwlms38O1G4bGVgdj8YNFNoYP2tDkN7ZzkWC9c16ZXM2jMIPm3lK4FMV3i6gS
 IuO2GrJ+hwJ/7cPSmKPAP/cxQnDAp6OQU8oxYAUg7CIpJEN2jbJhS5NzE78myYcPpe3RTt7a2X
 UahSH7wMNGfAiXGEzh3aj5jq
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 14:04:18 -0700
IronPort-SDR: vbYbPQo4JkJT9Bw0pHc9exinGYDWPnbSJXW9OLyStr6Ikua7imsg7WGL9OFLdpmqGZYjTYx4JR
 SlQ0ebyX4o3dktLi0pIW6wZ572FFPS4eEpARRdDJ5E6EgXE9NuAFcgQ6LmSZMAeAsKsw3A1pol
 Z6mvT2BqJX45lL9lr9CS67zyQFTC61d6y2n2mWaugkXK+yxgesD/SEzWnHXi11nISjMimlDbwv
 J+yaXneSbTiDtMFpy97ZI5749qNhEvodmfVdlmVrU50MSSmw2w40zd0YHjYCC3ZZISmvcb5/Ci
 WGc=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip02.wdc.com with ESMTP; 29 Apr 2019 14:27:56 -0700
From: Atish Patra <atish.patra@wdc.com>
To: linux-kernel@vger.kernel.org
Cc: Atish Patra <atish.patra@wdc.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anup Patel <anup@brainfault.org>,
	Borislav Petkov <bp@alien8.de>,
	Changbin Du <changbin.du@intel.com>,
	Gary Guo <gary@garyguo.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	x86@kernel.org (maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)),
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v3 1/3] x86: Move DEBUG_TLBFLUSH option.
Date: Mon, 29 Apr 2019 14:27:48 -0700
Message-Id: <20190429212750.26165-2-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190429212750.26165-1-atish.patra@wdc.com>
References: <20190429212750.26165-1-atish.patra@wdc.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_DEBUG_TLBFLUSH was added in

'commit 3df3212f9722 ("x86/tlb: add tlb_flushall_shift knob into debugfs")'
to support tlb_flushall_shift knob. The knob was removed in

'commit e9f4e0a9fe27 ("x86/mm: Rip out complicated, out-of-date, buggy
TLB flushing")'.
However, the debug option was never removed from Kconfig. It was reused
in commit

'9824cf9753ec ("mm: vmstats: tlb flush counters")'
but the commit text was never updated accordingly.

Update the Kconfig option description as per its current usage.

Take this opportunity to make this kconfig option a common option as it
touches the common vmstat code. Introduce another arch specific config
HAVE_ARCH_DEBUG_TLBFLUSH that can be selected to enable this config.

Signed-off-by: Atish Patra <atish.patra@wdc.com>
---
 arch/x86/Kconfig       |  1 +
 arch/x86/Kconfig.debug | 19 -------------------
 mm/Kconfig.debug       | 13 +++++++++++++
 3 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 62fc3fda1a05..4c59f59e9491 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -132,6 +132,7 @@ config X86
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD if X86_64
 	select HAVE_ARCH_VMAP_STACK		if X86_64
 	select HAVE_ARCH_WITHIN_STACK_FRAMES
+	select HAVE_ARCH_DEBUG_TLBFLUSH		if DEBUG_KERNEL
 	select HAVE_CMPXCHG_DOUBLE
 	select HAVE_CMPXCHG_LOCAL
 	select HAVE_CONTEXT_TRACKING		if X86_64
diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
index 15d0fbe27872..0c8f9931e901 100644
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -124,25 +124,6 @@ config DOUBLEFAULT
 	  option saves about 4k and might cause you much additional grey
 	  hair.
 
-config DEBUG_TLBFLUSH
-	bool "Set upper limit of TLB entries to flush one-by-one"
-	depends on DEBUG_KERNEL
-	---help---
-
-	X86-only for now.
-
-	This option allows the user to tune the amount of TLB entries the
-	kernel flushes one-by-one instead of doing a full TLB flush. In
-	certain situations, the former is cheaper. This is controlled by the
-	tlb_flushall_shift knob under /sys/kernel/debug/x86. If you set it
-	to -1, the code flushes the whole TLB unconditionally. Otherwise,
-	for positive values of it, the kernel will use single TLB entry
-	invalidating instructions according to the following formula:
-
-	flush_entries <= active_tlb_entries / 2^tlb_flushall_shift
-
-	If in doubt, say "N".
-
 config IOMMU_DEBUG
 	bool "Enable IOMMU debugging"
 	depends on GART_IOMMU && DEBUG_KERNEL
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index e3df921208c0..e8622b26f0c2 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -111,3 +111,16 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config HAVE_ARCH_DEBUG_TLBFLUSH
+	bool
+	depends on DEBUG_KERNEL
+
+config DEBUG_TLBFLUSH
+	bool "Save tlb flush statistics to vmstat"
+	depends on HAVE_ARCH_DEBUG_TLBFLUSH
+	help
+
+	Add tlbflush statistics to vmstat. It is really helpful understand tlbflush
+	performance and behavior. It should be enabled only for debugging purpose
+	by individual architectures explicitly by selecting HAVE_ARCH_DEBUG_TLBFLUSH.
-- 
2.21.0

