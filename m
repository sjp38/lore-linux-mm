Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CC22C46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:01:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EC5B214AF
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:01:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EC5B214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 874048E0005; Tue, 18 Jun 2019 12:01:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 824548E0001; Tue, 18 Jun 2019 12:01:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73A4A8E0005; Tue, 18 Jun 2019 12:01:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8B28E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:01:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b24so8040990plz.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:01:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6E2GD28gLWT06212squaTJfa5siGlOHjnRSYK5oIen8=;
        b=buwBJm4lMpkk2PGRtYZ4f8TgAPgRKKGpl0B4QZcTnHwbzLmOMGzYThqwuOE3D091nq
         q8CYCfJz6hVw0YgfZpeUTHxadoGyOnhazuulSZ2J7+DJ9NOy7U8KKnAPnvYMlBRGgs61
         4JVQ1g7u1SlUPdr9peuca01mULGoKOgDCr6FiIk2DG/QXNEGf8+q0w+hCSwezstG9x3w
         ONNS7MujK5IlXVo8qgJeAqf3TQ8sqq4/G3P3YUKoQxfXNeqL1/UmGwgxyw5X2qHSTzCX
         mrk26BujHK2YnEu7ALzourgkPrOmVxQ1xfbPwkyOs4woO4g0GdM/Sr/jTdzuq39OmuFD
         +6Kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXzCDT2d//x88htrvBGkvKhR6XxWOhcL8AR21LZHqAr0npteO6G
	RmSgdtj0TQYcM5vpyfwkt5zkQeY2C3ypuOWYjyPGFGqyu8jbgtVW+AMFItnpEc36+ruQMyFbb9l
	BoKqlFAYnhiy6Weqq5wOElTLYWk7hCXRj017BVpdzp9yKybmuW2Jeau+R8G4IlsLysQ==
X-Received: by 2002:a17:90a:3724:: with SMTP id u33mr5878652pjb.19.1560873699948;
        Tue, 18 Jun 2019 09:01:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA8cJEVb/0rFmaboZegim9P3GhLBxmBXPxz55pY71WwXLRA4rEuZ1Jc8jRfOgikyKnBrc5
X-Received: by 2002:a17:90a:3724:: with SMTP id u33mr5878588pjb.19.1560873699298;
        Tue, 18 Jun 2019 09:01:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560873699; cv=none;
        d=google.com; s=arc-20160816;
        b=A7bUE7aFczqe0k5umQ2bkFCY5PDHiK1pioQ3V2WaV1pLI5DY3j1WS+EugBd9MMy2hT
         nyPDSsJYe9a2IBhYwR6p2VXSQ2IlPed4bV9B55R3GsrD3eeektdiwlsSZC8XdQdDwo4y
         n3miqY0phE/e++GVqDuYLpaTxTGCoY9+4v3khZ5LNNilpMTzz3HhH7lPv4hkG/t99ERG
         WP/DhQ6kA9oi4S/QwdJTvv59jhjcZKZ7o9j1wwKHFsY1gp3hMw6KgaHaZnJQrNVo+RKB
         qc5ffdzf9Dh8T7xIr+oVMdMEy2OrPrZvENYK65ZUhC4nIVd+jtr0fJjrd4s4cNucYFdg
         uALA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=6E2GD28gLWT06212squaTJfa5siGlOHjnRSYK5oIen8=;
        b=tlyLl28sTD8stkhXxeh3/CuO6GMbFCiUTnaciGuRjaclxfhEpmvetbFMGJQT4+2s02
         vV8zio8hS41k1kIIhK8hq9KCaRI7kWN6HZDePziIYn+No7rLAjnqxR/vtxZJGL1BssEV
         IzcDyXI3iD8TOuW0Lla5bE6osReRYuaarskUnBsXHIRA7EIeVebMJ32gvgw1yMCHiiVp
         kM0x26zU4RkSWek/gOglanyHFXQhMYg7yp9HWtZoxiM+/kZBsN3CBt2oNYrx/4kxVi1i
         uULR6qPbkBukH/Gy/9iMnNK6+JoeKDcsSAnZs0VK7+LFU2w9r5EyHM5qQTQ2ngCagXcv
         Dv7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h32si2335578pld.402.2019.06.18.09.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:01:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 09:01:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="357901271"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga005.fm.intel.com with ESMTP; 18 Jun 2019 09:01:38 -0700
Message-ID: <1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Peter Zijlstra
 <peterz@infradead.org>,  Thomas Gleixner <tglx@linutronix.de>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar
 <mingo@redhat.com>,  linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org,  linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan
 Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Date: Tue, 18 Jun 2019 08:53:29 -0700
In-Reply-To: <87pnna7v1d.fsf@oldenburg2.str.redhat.com>
References: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	 <20190611114109.GN28398@e103592.cambridge.arm.com>
	 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	 <20190612093238.GQ28398@e103592.cambridge.arm.com>
	 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
	 <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
	 <20190618091248.GB2790@e103592.cambridge.arm.com>
	 <20190618124122.GH3419@hirez.programming.kicks-ass.net>
	 <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
	 <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
	 <20190618133223.GD2790@e103592.cambridge.arm.com>
	 <d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
	 <87pnna7v1d.fsf@oldenburg2.str.redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 17:49 +0200, Florian Weimer wrote:
> * Yu-cheng Yu:
> 
> > The kernel looks at only ld-linux.  Other applications are loaded by ld-
> > linux. 
> > So the issues are limited to three versions of ld-linux's.  Can we somehow
> > update those??
> 
> I assumed that it would also parse the main executable and make
> adjustments based on that.

Yes, Linux also looks at the main executable's header, but not its
NT_GNU_PROPERTY_TYPE_0 if there is a loader.

> 
> ld.so can certainly provide whatever the kernel needs.  We need to tweak
> the existing loader anyway.
> 
> No valid statically-linked binaries exist today, so this is not a
> consideration at this point.

So from kernel, we look at only PT_GNU_PROPERTY?

Yu-cheng

