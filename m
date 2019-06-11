Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBF12C0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:39:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 916902173C
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:39:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 916902173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32AD96B0008; Tue, 11 Jun 2019 15:39:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B55D6B000A; Tue, 11 Jun 2019 15:39:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12ED26B000C; Tue, 11 Jun 2019 15:39:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D00366B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:39:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b127so10294411pfb.8
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:39:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OPD6t6WRH/wtqQO7lyfv8+60SYjhrw4wFvg76G79SVU=;
        b=OCuXRb9bjShXeB3JOOQm1gD0Wkp9El+SxYZzoaURijtVoKNqYPYFRds+kGg2urGNgM
         EnL31eIxQRk7li+hv0UpgcCd597pbq7ZrgqI6sOo718oafIcfcjDJYcfPZUR/uuL/i1y
         6H7PrCqTpqgKL1mZWUue7xtsaD43hSDALbPwbBxMBNSLUUNPSMmM0XAeqcXV3anVJMg5
         Gr/mRBWwtXV96HURAbjwFXHPhJzMJf7LRfRIDjnfo5m6Xz7DtNWy0Bee4O9/xILdiIp7
         E/5D8GdbDac8r3WPrYNubbKx44gXLJpRp/FpP/877OQ31MhoRQihJY/zYwvKEKiRcyu1
         iF6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUT1mjg0oZKrkWads15R4LoB+JCrgzAF5CFLWrK0iwWitvmm1Xp
	CRsTlkND3GkESc77/BGNbKEpWLr2/4Om2LS+3qann3genNsjx2xectKTqXjlsOXh5fEGJLb0zgx
	dCW601hMPyN+p0xzxagPo6mSL31vLizyHkw2kTFtLFhMpGOeBCPJa7DSm4CKLUrQyLw==
X-Received: by 2002:a62:e041:: with SMTP id f62mr56808936pfh.128.1560281985507;
        Tue, 11 Jun 2019 12:39:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9OLhzg/TbOQUPraPL7OcWGDmvUOzQhavQwO9EI6GLOymB3kjfhgPh5ZGuITaI7yGyVsYb
X-Received: by 2002:a62:e041:: with SMTP id f62mr56808880pfh.128.1560281984647;
        Tue, 11 Jun 2019 12:39:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560281984; cv=none;
        d=google.com; s=arc-20160816;
        b=ZqduQz/WQB/zOS+HgqFKbqFtRnUJOsUTzbduAuI+ZojeyTebAqQjCVuhAJifrQ0tAE
         9QarYg1wGetFSqXiofXNufjUeFS6wt8GwBKU6Ob6p7xSqVPR17w+weJ/ALIklWS/5hni
         ZOQ2Vh0KyiozHdCaq1Wd8CbDwWeD7OLeiWHHzuUPBsgk8ItdMd22f+NQPYH9thnojbIA
         yv8sQfXfjZ2H2mzMahjkapUTony6l1Sr+BqkQ3ZwVKMOFn83Px47a7he3mr+76sNCQcG
         Dd+htP2yeT+8ud4m5LN/oEl+ccoENPE36sAgXM+B/HXDP6NLuZgMM8lcLMipzNuLAZUc
         5bog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=OPD6t6WRH/wtqQO7lyfv8+60SYjhrw4wFvg76G79SVU=;
        b=m5bMzwe0veFkPTkMWp7rZWDJ7uPhC7wb7SMxYmIxMWbDoGxw/p+Oz9FCXu+9tAPGzm
         j6FoS8JkbEfJPCruT1O7c7EAzxU7HbZ0BqxD1x/bVDtReldMcMaQJJXh6foyA4yMkrC+
         WjFejq68j0r8pvcnuQ/YctPwKwtFiGbg2ldBNjerGV0I31Slmsaw7HnVriSr9MBDSNLk
         26HcG6AEiYbrBEPrqR/AAkbHkYT+I2oEARga29XiRFFgpQZvQ4MnTUM99nryf/dyFU1O
         9oESyxJAzlC/u2YxOCVApTP5p/OTp45DWqZyK6KcmOCGAA4i1fqq9YNq7bEjcdpLnV4u
         wi7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q10si12715582plr.412.2019.06.11.12.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:39:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jun 2019 12:39:43 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga007.jf.intel.com with ESMTP; 11 Jun 2019 12:39:42 -0700
Message-ID: <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>, Florian Weimer <fweimer@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan
 Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Date: Tue, 11 Jun 2019 12:31:34 -0700
In-Reply-To: <20190611114109.GN28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-23-yu-cheng.yu@intel.com>
	 <20190607180115.GJ28398@e103592.cambridge.arm.com>
	 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
	 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	 <20190611114109.GN28398@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-11 at 12:41 +0100, Dave Martin wrote:
> On Mon, Jun 10, 2019 at 07:24:43PM +0200, Florian Weimer wrote:
> > * Yu-cheng Yu:
> > 
> > > To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
> > > logical choice.  And it breaks only a limited set of toolchains.
> > > 
> > > I will simplify the parser and leave this patch as-is for anyone who wants
> > > to
> > > back-port.  Are there any objections or concerns?
> > 
> > Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
> > the largest collection of CET-enabled binaries that exists today.
> 
> For clarity, RHEL is actively parsing these properties today?
> 
> > My hope was that we would backport the upstream kernel patches for CET,
> > port the glibc dynamic loader to the new kernel interface, and be ready
> > to run with CET enabled in principle (except that porting userspace
> > libraries such as OpenSSL has not really started upstream, so many
> > processes where CET is particularly desirable will still run without
> > it).
> > 
> > I'm not sure if it is a good idea to port the legacy support if it's not
> > part of the mainline kernel because it comes awfully close to creating
> > our own private ABI.
> 
> I guess we can aim to factor things so that PT_NOTE scanning is
> available as a fallback on arches for which the absence of
> PT_GNU_PROPERTY is not authoritative.

We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
version?) to PT_NOTE scanning?

Yu-cheng

