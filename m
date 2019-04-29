Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E4CC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 552DC2075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="m9WkW3Cy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 552DC2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE7616B0008; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FC256B000C; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6505C6B0008; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF526B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d21so7869161pfr.3
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:58:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ENMwfs4sHluJwyT9doR8c5yMfngquoTFJE3lgUvSzmo=;
        b=KVotaI5ntP1yA76BooRKUqOYg6bpczPvuASLK2yXxOf5rXXORgqLndtQAu7hmua7Jb
         vV3e894W0YmmauVslUNzxZnaor74Yo6cUd7dhI51vvhsfD7Yl+7SGBGqWooc0pJP8BlG
         h6CvcYVeuvzR4iyb3YhF28ivpEkN0bfmR1uDLWfIH8T1Kol5/wGM2yGF7WOM34EjVSpR
         33Aw2mZqGR694kBoZMaIzQNT/CmBCZ9shmJj5OHQ1uYf2ty1B9kVzw1SrX9WauiKzFtR
         fcI3pPEFzJtt5zT0rTIWv9zpclonvfT6uNWv99M5XIOPaoFigHXdh/KULD5vF0lhQ71Y
         V3hw==
X-Gm-Message-State: APjAAAV8BmnHagXPbmC+1xYudPOU80VeOLLn2nA+5R2V0/3/szA8ZdG8
	INVF2/YGYAGQVf9IrBP6Kqu+LndgA+o93BtTpCWQ9DNNbes2w60hcfeHwx1krcDdm/0raVv4nYw
	EIBqIL0k4xnsp4G7THfolNm1UwciyHczkVY5qitj93QSurmTaBK+kd3/I/WZdllxSmA==
X-Received: by 2002:a62:ed05:: with SMTP id u5mr64099762pfh.63.1556567909739;
        Mon, 29 Apr 2019 12:58:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3tKddr4N53AhczecSIJpwfqf4qhBdfGf4TuRkpPz5Ng8f0y9JoIl7iwIE7TDosR23V16+
X-Received: by 2002:a62:ed05:: with SMTP id u5mr64099634pfh.63.1556567908472;
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556567908; cv=none;
        d=google.com; s=arc-20160816;
        b=Pfk+i/lB7dTKWXYxhLKt3Z1G9AioUzZF0x1qwuriPJIW1BCy0VaD9YpmuXrzfL+Y+a
         PeaGEgf76j3JZqsyVuvwwl6eVf9r1m+VaVRth1fuxCazbbMojdNsmuNNFNpBjll8GorC
         IQFpun4gDg06ExAWdiPbKK0FiJyfqZs7PfhZOBg+In4WTeDyLwJP+rdAVWN2but43rbt
         KevAT+nlcWQCw5C02nd8kWfoD5vIf0L7rh99gylFcDm0tGxjxZUzk+lnr1LWMah67irk
         q3JCyMIZDyT+MbdelFdkZMUMgevX1cwoM0Lg7xGO8tecIMpNg3p4WijSseC+67yuzYHu
         byew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=ENMwfs4sHluJwyT9doR8c5yMfngquoTFJE3lgUvSzmo=;
        b=mdspPOABwsWzwztCF5OBk7m7bD5rzJDOKL3GB27GfMzvhCxIKc+iAXrJOILbk9Tqag
         OSBuXCAlbgadar24h6/ryRrjDTkK52LiPZf8n9e3AFrpoJVv6hNGI8M5D0RYQETCL3jc
         XDxt5UM3/K4A+mYMg4G8YOoCKlRRnC2SIkqaMHPHhSvi72neWVlIlzOgJ9FTfjx9EeQO
         ruIHcnXBhqa+FMb3X6GqqPjBbOEHW3YQiUt/uHQmoGz/t1rP2aD2++Cr/R+Qm+mmGxyE
         U1+kz833J7cjhPV97V0qrRbriA0A5OGEJuqPwRRCvZreWmzcBd9r3AUnrTLeISm14LIn
         Moyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=m9WkW3Cy;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id c3si34040478plo.243.2019.04.29.12.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) client-ip=68.232.141.245;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=m9WkW3Cy;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556567908; x=1588103908;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=GQpKXJ6rfJbjxybm+qOYB3z1XmPhKagdgdILF7N0WwA=;
  b=m9WkW3CyoJ0xdoGw9nilS1jXk0EC9w4+iAIX7YTyk4IhawUfNuJ0LfyI
   5zCtbtU5dbdzPru1A2aB8mQZqVdci11Of4IWgDHOxzdmEg6ztt1xuwIM6
   Z0ZIzM6k1YKwIkA1bSaJybLWSevNJ7lQn6mqHEiPkwqhi4h3e3cHTwSmM
   S+2Yllc/lQ7uXgWkUT4WoT8+IBak10DSdyWJij00LvPvskHrCShZvAOqg
   lzjcWVynBkMUmgelbiBwWznoVG23fX76L8rTZjUMGBBb537+8aCCPOafQ
   c5nvjj0Au/hKkeZNlInsmvtAEAo8mMFCneTmbUDh7/lq6bJk5Gs2dznpS
   Q==;
X-IronPort-AV: E=Sophos;i="5.60,410,1549900800"; 
   d="scan'208";a="212999870"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 03:58:11 +0800
IronPort-SDR: jBjPovgmsobnZmrrksjuxix2kl6D7esOMHIhvxag0FPlRNBWDsDbkROf2CBhIFmUJS6eLu7V30
 2ZZ4feR9PB/wS6t5iiiXZK1w1UOtWFRMudD5G91akZJxKivfA3RCPY+x+3eSzPpmYPPgeU4sHC
 mOM03NruN55doZhvRRMvJ9qKwpP+Bj2RnYxe4KGofEC8BGJXbGdN45DZnsnl1xiX2T/6x+kzBb
 y0+bi6hkj62E8LjT5MJuGuHz0IOtteDJZnLs3ksnM/20xU9xBH66KiPmvEUWwyrjHMp3k++fdj
 NDc+IbXr1hpa/9/e1vcvGXG1
Received: from uls-op-cesaip01.wdc.com ([10.248.3.36])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 12:34:34 -0700
IronPort-SDR: wz9YGcayYviARxURW0XYZuUzYVCZFmYVx0XdGd5JZHZiNh02M12LMvPMG8IMYcAtZPZcy1EeDb
 h3W9jYm/1FQlZZHxDvV7Prowbsd3Hyz1a/RTdWFHN0r5GMxoiiiDXhfxhLeiwqugDGnA05Ljq4
 moiPxBN2X9YhDPIWKJYtQve9/hgsixthYTDEgtOkb23Yld3IOO/JdsyvvCGFG92A8VPkK75xXs
 A9KKcfbWLwIjssH3PDU+LBp77MSbbrSFkbhUoC8pi5FigiTn+C/eTzzxNX9qF9uVZ00cmOxTce
 epM=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip01.wdc.com with ESMTP; 29 Apr 2019 12:58:11 -0700
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
Subject: [PATCH v2 1/3] x86: Move DEBUG_TLBFLUSH option.
Date: Mon, 29 Apr 2019 12:57:57 -0700
Message-Id: <20190429195759.18330-2-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190429195759.18330-1-atish.patra@wdc.com>
References: <20190429195759.18330-1-atish.patra@wdc.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_DEBUG_TLBFLUSH was added in 'commit 3df3212f9722 ("x86/tlb: add
tlb_flushall_shift knob into debugfs")' to support tlb_flushall_shift
knob. The knob was removed in 'commit e9f4e0a9fe27 ("x86/mm: Rip out
complicated, out-of-date, buggy TLB flushing")'.  However, the debug
option was never removed from Kconfig. It was reused in commit
'9824cf9753ec ("mm: vmstats: tlb flush counters")' but the commit text
was never updated accordingly.

Update the Kconfig option description as per its current usage.

Take this opprtunity to make this kconfig option a common option as it
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
index e3df921208c0..760c3fda8b57 100644
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
+	bool "Save tlb flush statstics to vmstat"
+	depends on HAVE_ARCH_DEBUG_TLBFLUSH
+	help
+
+	Add tlbflush statstics to vmstat. It is really helpful understand tlbflush
+	performance and behavior. It should be enabled only for debugging purpose
+	by individual architectures explicitly by selecting HAVE_ARCH_DEBUG_TLBFLUSH.
-- 
2.21.0

