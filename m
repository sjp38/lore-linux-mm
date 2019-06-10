Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30916C31E41
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 15:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E47772089E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 15:30:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E47772089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 733216B026A; Mon, 10 Jun 2019 11:30:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4776B026B; Mon, 10 Jun 2019 11:30:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FA866B026C; Mon, 10 Jun 2019 11:30:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 293D86B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:30:43 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t2so2074378plo.10
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 08:30:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MF3WpivqAiB8TBMRkoC4q1w6Zv70Srs8sXkUFVNG9vg=;
        b=YLgVFOq6UGvzemXf8GG7ThOWy2fxR6PWGD2dbbc7/U79gWnOn1RmnjfkqsRHzB1s/4
         HTnl1RGXkM5rH5C/2e31Mm9fEGw/ZXJFX5cNh2GHZfRlWpJuN5mJ4Sc0Bdui5qwuGeFv
         R7k1+XfgYByyO1dtt+JeAQpTj2blUvRR+mGAF6G3pNGhux4kQh3DUrSjZN2eb507KL+7
         0wKuWGtOXVFLHFBTkxgswFDiOBUEZ0RF0TsgImrIepg9WnbNo/g44NNw3FYRaxN34qG4
         eC7sDlh6blyLxHoslaSS7qTkz8s4oBuCnZyOVUUITdSLipmQF84dDollgexN7TXI5nz3
         tPFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWlMZk0/tbckdJrPDOHn469KFB1TOfveHKJG3DmDDDrpiCHJedu
	pNuove3EquAeTHMkgqBA6Jm0ZESyZu3cqZ53/U30TJKpaDP3EWf8DB8dCRmx1KsHVaXkPGI3TBe
	w0ChZdXDxaSUdcHcO7ioNHSeBf6VABv8d8eobVUGuT3antV1+MfgIR6t6ONYyQnSs7g==
X-Received: by 2002:a65:4786:: with SMTP id e6mr16132427pgs.85.1560180642095;
        Mon, 10 Jun 2019 08:30:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5u936LUaofPvVFJmXgzP8bFa1OQL6KbqZ2SlOIfmFZx7nlF9OFz7o1Y2DnKWPWP9NuX5a
X-Received: by 2002:a65:4786:: with SMTP id e6mr16132298pgs.85.1560180640210;
        Mon, 10 Jun 2019 08:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560180640; cv=none;
        d=google.com; s=arc-20160816;
        b=CWEA2F69AeFSfDZEBU2qju3vyupMvbY58cvQ4g1a6r+GkIs7zu/j75SbFPq/TH2+F7
         N3mlGyrETlPKqabbuhPFPmJeUiR/0+EB7+I4uejsWlKCJkizY4xj+kF3lEq+zxuqgoJN
         Y6kex5Ru7I9Q49oo0Z6Ys1CSJlHzOHF70Gal5Hm9jH76kkcNOU7TpcJEIEj9PFdeslzu
         ZTsjprQiXnyfJrXi3T+mit8kz6VnifTXIvqNA1E2VqU6uB1ZI0N/Qpyrt+2RpEVyf1nw
         UkWtNZEoTZGUeXntb4tMW7ruGGzZY+ot4Ro9YvtM66L4g/UGQQunhPWMKWWAyWib5/nx
         vLww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=MF3WpivqAiB8TBMRkoC4q1w6Zv70Srs8sXkUFVNG9vg=;
        b=W/ewKnU1NpH30HeJPdNg9IgiKLZMVF0WKqOPUgrFC2fsiQufqNMzyeo1r9o/fYeFyr
         6W23RLnmlQjZn6/Dd5sMzqmAOh2pvFudAH5RnyrEp0MY0WVnpeCCdADO8uju6BWmfmtJ
         JrvJhEe9NhTI0VjzgRva08anuyVK6w+TMm+kvL61lCy3x//8H7L+sPGY/HjV1IQ+q9H9
         bZSWZxZB2kV+FJ3FWzR0gXRNR9zcMFjBzzR6+d1Rzlzh2dpm+Sc7f15ADM7OCW+wAn61
         UGvDTkEIGBQL/nhOgd539p0PWmsqCEdRCpfkjaZ2xC27D3k4wyS/Nt6k/87phq22mds7
         3B9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d19si9787047pgl.152.2019.06.10.08.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 08:30:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 08:30:39 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by FMSMGA003.fm.intel.com with ESMTP; 10 Jun 2019 08:30:39 -0700
Message-ID: <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra
 <peterz@infradead.org>,  x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Mon, 10 Jun 2019 08:22:33 -0700
In-Reply-To: <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 13:43 -0700, Andy Lutomirski wrote:
> > On Jun 7, 2019, at 12:49 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > On Fri, 2019-06-07 at 11:29 -0700, Andy Lutomirski wrote:
> > > > On Jun 7, 2019, at 10:59 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> > > > 
> > > > > On 6/7/19 10:43 AM, Peter Zijlstra wrote:
> > > > > I've no idea what the kernel should do; since you failed to answer the
> > > > > question what happens when you point this to garbage.
> > > > > 
> > > > > Does it then fault or what?
> > > > 
> > > > Yeah, I think you'll fault with a rather mysterious CR2 value since
> > > > you'll go look at the instruction that faulted and not see any
> > > > references to the CR2 value.
> > > > 
> > > > I think this new MSR probably needs to get included in oops output when
> > > > CET is enabled.
> > > 
> > > This shouldn’t be able to OOPS because it only happens at CPL 3,
> > > right?  We
> > > should put it into core dumps, though.
> > > 
> > > > 
> > > > Why don't we require that a VMA be in place for the entire bitmap?
> > > > Don't we need a "get" prctl function too in case something like a JIT is
> > > > running and needs to find the location of this bitmap to set bits
> > > > itself?
> > > > 
> > > > Or, do we just go whole-hog and have the kernel manage the bitmap
> > > > itself. Our interface here could be:
> > > > 
> > > >   prctl(PR_MARK_CODE_AS_LEGACY, start, size);
> > > > 
> > > > and then have the kernel allocate and set the bitmap for those code
> > > > locations.
> > > 
> > > Given that the format depends on the VA size, this might be a good
> > > idea.  I
> > > bet we can reuse the special mapping infrastructure for this — the VMA
> > > could
> > > be a MAP_PRIVATE special mapping named [cet_legacy_bitmap] or similar, and
> > > we
> > > can even make special rules to core dump it intelligently if needed.  And
> > > we
> > > can make mremap() on it work correctly if anyone (CRIU?) cares.
> > > 
> > > Hmm.  Can we be creative and skip populating it with zeros?  The CPU
> > > should
> > > only ever touch a page if we miss an ENDBR on it, so, in normal operation,
> > > we
> > > don’t need anything to be there.  We could try to prevent anyone from
> > > *reading* it outside of ENDBR tracking if we want to avoid people
> > > accidentally
> > > wasting lots of memory by forcing it to be fully populated when the read
> > > it.
> > > 
> > > The one downside is this forces it to be per-mm, but that seems like a
> > > generally reasonable model anyway.
> > > 
> > > This also gives us an excellent opportunity to make it read-only as seen
> > > from
> > > userspace to prevent exploits from just poking it full of ones before
> > > redirecting execution.
> > 
> > GLIBC sets bits only for legacy code, and then makes the bitmap read-
> > only.  That
> > avoids most issues:
> 
> How does glibc know the linear address space size?  We don’t want LA64 to
> break old binaries because the address calculation changed.

When an application starts, its highest stack address is determined.
It uses that as the maximum the bitmap needs to cover.

Yu-cheng

