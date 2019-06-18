Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 790EEC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 384A720B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 384A720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF0E88E0007; Tue, 18 Jun 2019 12:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7AA68E0001; Tue, 18 Jun 2019 12:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F46E8E0007; Tue, 18 Jun 2019 12:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 652C68E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:08:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e7so8070909plt.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:08:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jUSJcSZPRnDk19Up/Q/AWhAgTjKe0JdfO9K1j5BKlfU=;
        b=Vp9Y816/Q2T22XtC5C+KKK5nKJqY00fIkhq86pT03ABcA4swRUHaj4c3qb2LPEhA8Z
         wmbl7S2xrivavsfeoWZLvCfvRtksxGASWgoPiq3mYAnEQO0KcjiGQ8DtIJ8YRuV0vSgx
         Z3F2DLikiDqSGbtDLaDiBxs5bwZoFL6k5KhXTlNWzqDIEr5POBCmYl/chh7ZTqoUTYDn
         +r8qXLPBwOOxumLDvoNLXcB9k8FVKLrt/DI9AW+PRZmy1GWgzIbvOEdZZIMgCl6nc8ok
         8cYUCf4ILCgOHEI942Jup6tMmASzUcy5RO+TLU47BaPUwEiz2Yg6VTKGeiAWp3u2SO41
         O9pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVIQkphKmYe2XB62xQ2gGQP8jP2WjSHdjah+tDOOTly8Xi2bek0
	j0j0doMV6ReH/IjPbwTeVaFB9Y+laKMfJcuFPFIkwNLmFUdM4DeKQ1hGArI7Y21w5pS5PA68iYT
	tElcvTw8O6rqLT0Yz0tK0Wc6uvgdZfwZojr269I3JHe9ng3/BOUSIAZ2RtTMHJVA9lQ==
X-Received: by 2002:a17:902:1125:: with SMTP id d34mr42214824pla.40.1560874126114;
        Tue, 18 Jun 2019 09:08:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4qQOPf+7+620TBd4sgxt61TTBNvCjjgUatCMcQJxLtmXu0p0CxUhh1ZmRwHmANsvSCkNU
X-Received: by 2002:a17:902:1125:: with SMTP id d34mr42214779pla.40.1560874125519;
        Tue, 18 Jun 2019 09:08:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560874125; cv=none;
        d=google.com; s=arc-20160816;
        b=FcYXiwfslLlHkwhHzBL2OmC0xhuNtpZfEWnoKOYkN/OMlk2eli1aFbIMQStztK4TDU
         n7cRVgexRA54nHTtutngzN26EX2dpn8QIWj7dw32tqZdqu4o1aawUltTOfdV6+7wPnq1
         bteM89LNG2yUcwHbeJO7AtmiBSkASK8xoyqoz3Vib9BYJc6gTIF6fxX7vqVmSOjGoPJs
         1iFVkhDqgBdFPixiiOkULZnh5OUySNeLtY8Rqnz6B8080ZjdIjSFCs++NGstWdnyyWEh
         yyxyyVfMFrpl72JDCkC8prD6a3RyycXra1E/VadaJWOy/GRbpB+dS9hfbsDQn6exBJFt
         /Hew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=jUSJcSZPRnDk19Up/Q/AWhAgTjKe0JdfO9K1j5BKlfU=;
        b=xpXKF9P953ohD3Tov8VXmVeho88FK8P3thIIRcmTnRXq/QOsBINR8Lu3tDQeLN4wbV
         r3OzZnxgh8uQpMlKhzEZAkl2LHhcR7JHyKq+y0OZVh1blUHiXO0ao61SkNvFVYI4fsX1
         ZKJUltW+c1dXO8Szmxsr1Ft6M8wXZLVykWyK82fkgFj02sQUs4Xq9rSU3QaOn6ZU8PLn
         3f6wVzROIHE8cFtfNI/WhO2jyYLYUdYGAxFOYqS0qxZQ/8QZ0SDMZU87KdtheQp3Rv9r
         kZGPZhYnxQQxys5sb2+UG4s0YE1B9L0y52MoidRqO9QZ/58+o+TBalA/4yso1s8Wcvlp
         nLpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o13si532444pgp.487.2019.06.18.09.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:08:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 09:08:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="358310992"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga006.fm.intel.com with ESMTP; 18 Jun 2019 09:08:44 -0700
Message-ID: <b0491cb517ba377da6496fe91a98fdbfca4609a9.camel@intel.com>
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
Date: Tue, 18 Jun 2019 09:00:35 -0700
In-Reply-To: <87blyu7ubf.fsf@oldenburg2.str.redhat.com>
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
	 <1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
	 <87blyu7ubf.fsf@oldenburg2.str.redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 18:05 +0200, Florian Weimer wrote:
> * Yu-cheng Yu:
> 
> > > I assumed that it would also parse the main executable and make
> > > adjustments based on that.
> > 
> > Yes, Linux also looks at the main executable's header, but not its
> > NT_GNU_PROPERTY_TYPE_0 if there is a loader.
> > 
> > > 
> > > ld.so can certainly provide whatever the kernel needs.  We need to tweak
> > > the existing loader anyway.
> > > 
> > > No valid statically-linked binaries exist today, so this is not a
> > > consideration at this point.
> > 
> > So from kernel, we look at only PT_GNU_PROPERTY?
> 
> If you don't parse notes/segments in the executable for CET, then yes.
> We can put PT_GNU_PROPERTY into the loader.

Thanks!

