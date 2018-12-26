Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B220C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E68E4218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E68E4218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27158E0010; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5B308E0012; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F1368E0012; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 859FA8E000B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so13984252plt.7
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=VHGacJehgC+4YcNMytQsBmtvZ7i7lp3jqF9SjGnKTPY=;
        b=DlaYonDzlljn5glskEhzh1gT1weAh9JMImBh0e06BWWE6hiWRjeBI+A07u3exeKYXy
         DIz4q1lz1319C9N/uXET5pyByvqzo4P+Nnv1fcIetrUQIY6lGLTReEu1G+SBfYhfJGDu
         ATa2iYLV2yfLbLuIJTs7pkOqat/Korq2jEFWLcXS7Q45AveDwZa+1gY5HFrzvBXjOkRN
         9mPf+e3krrwv+FUKsqCa5KY42gb9kv5I4ZBXM/MF5UJk0dFkQDhQ3Wac3920nvSnn7s+
         Laj3MaPY6yReCFLRtY1LrR13zOfvsMfc2QFxhY5++Tv8FzpJCADmoOT9bhIFu0RFIwA/
         5fNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcN094yhzNi3VrzfT8HAJESrakdeh7pW2lAQgwmyP9+ToNH0+MV
	rzMgj9OqCiIkxIlNcugjVjRBO1iy3P50gU0167hQnLlfxgXU6ZJ8CfsG3l9KqpaS6IFiPaVg7wb
	tnbFwGH7g2M5Ct0P4J/8Cb8WWZ8O+ZcNOrpwwkkoUqEGAoNPKuTUIUn/gFzU/4R4USg==
X-Received: by 2002:a63:4002:: with SMTP id n2mr18661852pga.137.1545831427241;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN657Fq+zbibRPsn6/INlnbtPgB427w+e0l5sLtovPcEOEQuOxX7WynE9Szq+idmc81UxhjN
X-Received: by 2002:a63:4002:: with SMTP id n2mr18661821pga.137.1545831426672;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=FiotiwQ0iwKjEZ7m1CDc8ViRiwrAw5yCvUgDWjC2fQIwswo/TRSDuXx9uNuoxCs+no
         NIts0gX7lUg6ui/2CBMVD46w7QDpwknfoXLzQK7vOWCPNO18PtCyKwpjByz23Fl+ZSvF
         7AnSPmvjym8x9M1zUk+SLxKba7G2xnneXNhLndNIH5GhLQcpUM/a37ALVXNWGtSjLENb
         Iod/EfT4LkHxaWHm87yliqGNhPmS2pm6R8aVjtvJV+p8YEY/oVe8n14S6jLEUF3Fo90p
         PnwmW1iJcsut8DpogAbQDI/4WL7wSBsjLias717CDV8s0M9RP24Tc85cCLIDVlNKAtDs
         tj4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=VHGacJehgC+4YcNMytQsBmtvZ7i7lp3jqF9SjGnKTPY=;
        b=n0WsFVREI7IHCYy4cPa5i+ThuDe/ejsYDNsTOaL6qXE4UnYzrDtRpw0zRfGq2BWOn5
         LHU1ZMOL9ibzPkC4lHRBWKKO75Lj9GF/WEEAdly1NRn39U1xOyx5I6QcVgyGBB+9yyHW
         xPcakvRIl7GfCsl0N5mK07Eo592wQ90z61U+VEmBMVselYTqdNF4nkHXdnfrvAQmmFHc
         wAIVrGjp2hFsKoZamJAWy7S+NLigSTL9qqkaVGfsI381bFjAFi5+be0wcBMSq9zywJEX
         PmosJARZI9wqvtaLrepGAe7RXZ8v2MGXrPEiZ0+KIsfdrjZPaStp+Ctnmu7jbIZblgoG
         6o0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185467"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005PI-LE; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133352.133164898@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:04 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 18/21] kvm-ept-idle: enable module
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0007-kvm-ept-idle-enable-module.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131504.7hfEQ_2kCn1QBrpT1ShwbJAjaRhBcU16vS8ZRh6pyJI@z>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/Kconfig  |   11 +++++++++++
 arch/x86/kvm/Makefile |    4 ++++
 2 files changed, 15 insertions(+)

--- linux.orig/arch/x86/kvm/Kconfig	2018-12-23 20:09:04.628882396 +0800
+++ linux/arch/x86/kvm/Kconfig	2018-12-23 20:09:04.628882396 +0800
@@ -96,6 +96,17 @@ config KVM_MMU_AUDIT
 	 This option adds a R/W kVM module parameter 'mmu_audit', which allows
 	 auditing of KVM MMU events at runtime.
 
+config KVM_EPT_IDLE
+	tristate "KVM EPT idle page tracking"
+	depends on KVM_INTEL
+	depends on PROC_PAGE_MONITOR
+	---help---
+	  Provides support for walking EPT to get the A bits on Intel
+	  processors equipped with the VT extensions.
+
+	  To compile this as a module, choose M here: the module
+	  will be called kvm-ept-idle.
+
 # OK, it's a little counter-intuitive to do this, but it puts it neatly under
 # the virtualization menu.
 source drivers/vhost/Kconfig
--- linux.orig/arch/x86/kvm/Makefile	2018-12-23 20:09:04.628882396 +0800
+++ linux/arch/x86/kvm/Makefile	2018-12-23 20:09:04.628882396 +0800
@@ -19,6 +19,10 @@ kvm-y			+= x86.o mmu.o emulate.o i8259.o
 kvm-intel-y		+= vmx.o pmu_intel.o
 kvm-amd-y		+= svm.o pmu_amd.o
 
+kvm-ept-idle-y		+= ept_idle.o
+
 obj-$(CONFIG_KVM)	+= kvm.o
 obj-$(CONFIG_KVM_INTEL)	+= kvm-intel.o
 obj-$(CONFIG_KVM_AMD)	+= kvm-amd.o
+
+obj-$(CONFIG_KVM_EPT_IDLE)	+= kvm-ept-idle.o


