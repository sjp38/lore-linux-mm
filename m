Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F1A0C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0155320820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:37:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0155320820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D5A06B026A; Mon, 10 Jun 2019 12:37:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886546B026B; Mon, 10 Jun 2019 12:37:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 727C36B026C; Mon, 10 Jun 2019 12:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5DF6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:37:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so7551930pfm.16
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:37:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lYaG9zCQ8qUR/NZZG6yx3c/iv2W/XOEvUKjl2KtFrZc=;
        b=Q2LsHMZHF1e4QXNsu36LOikTqETtCMA2MoeKYxHrmGaReRaysfjEI8S+9ZU2MbC9ii
         WvOzyrWss32ppHOOlKwwUEZPC98/cpIhuPtPKeGifQq9RhF6fVNDR64+TqIvgh+6Z3Qh
         7C7ihyzUJ/0206/dV1S5sr9QcW+fHVN+wyZhqUZkPUAWet1auTtDgkKl24ZhSnfUhIA2
         M8guWmIYcfkDD9snQgtxwPyiiGJc4xHczVSGmgMbJ8S3JMwrVW0Q6GzDwoKFdMU/eiCO
         dL/MufIIr5+pRij7loXAD++aSAnTImmJjhtGibqyDF0qSWxlyoH5MMV9MughAEcJH64F
         wfNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXkL5KHDBaN509zyEpaxTwcElCh6lOgRuSgUstAjJktqsGj8kx3
	gYsL4LJf4OYSqiTT0mWBg4BeTeHtbc3xwngIJFh/mIQKPJ9Wrb2qMK2yb9G8no8Dyf9R+9LhWBW
	V+7OG8rUP4qvc39UkIJGkoF428Ik4dakwClF7fo6YwDKkiIC7MFY3lbD5JPsl0w+MfA==
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr22271731pjn.119.1560184632843;
        Mon, 10 Jun 2019 09:37:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBD57HTe+CuF0ReUGkVmzqTpj1I2W31L1KSERV+TQSs36FNXrKSwRuBDxr92bPwj4Eky+4
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr22271683pjn.119.1560184632119;
        Mon, 10 Jun 2019 09:37:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560184632; cv=none;
        d=google.com; s=arc-20160816;
        b=F9WW1UrCzeeVPuOGyXrvITzubmb2Vvias3x6wiUbXl0SgtsBnQWi6/v9sw9xuRkPxk
         Ok0C76WG6C/8t+syEBB6wA9FAN6SdB9ugB9oLbuKPlU5sXG5W1N7EG2+syPiax1q6Vv+
         dsLKfkw2sE6Rq6u9+uTWADT70MhBidCYkXnXGsWEpQGiKH3BTCU0DzuVI5obJi7Z5eoh
         9bGcqkIM09yU+8xXz0SXlH5DYzTswejLp06hReAl5WvOLVUOCW7Q8E+aJ3jXwrQz5pGr
         lexkkOZRbAy0cKNAWCFCTQXELsGoDO1JMv66fxy4tca0/QaKVWutheZznUS6fePEpFQ+
         1k2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=lYaG9zCQ8qUR/NZZG6yx3c/iv2W/XOEvUKjl2KtFrZc=;
        b=tTYMe6TYOFUHCdcVCu0CqCFGPW154vi7s3UTvr9r5v3JwcWPsRQbyZRmM6TPVl5ZL5
         2uU7A+hgyQBYyScsxkmSGRW0t/YYUiKeqi7zEyaNTrVLQRGNZ0PxKzvrvbL8lgupvcZ5
         8WohPE9X+EbJAn56bFFQkds1Dp5BRq+M26oJLO4unnthltsnQzs9wVy2bGwkMg/3cVn3
         6Pd1uyTEq3jbL5LV0Reco/BfFg2VTK/QSNTvnln17EShSfDmcaZ3FSwpAALkq0Dq2KJ4
         LQwm15xq3VagJSjqpImmIndTd1jjNa/Zt7tJ9qLLpE3L5F/gGnaRm1pFggAC5Vz3HTbH
         JB6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s10si8959040plq.129.2019.06.10.09.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:37:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 09:37:11 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga007.fm.intel.com with ESMTP; 10 Jun 2019 09:37:10 -0700
Message-ID: <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>, Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,  Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Date: Mon, 10 Jun 2019 09:29:04 -0700
In-Reply-To: <20190607180115.GJ28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-23-yu-cheng.yu@intel.com>
	 <20190607180115.GJ28398@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 19:01 +0100, Dave Martin wrote:
> On Thu, Jun 06, 2019 at 01:06:41PM -0700, Yu-cheng Yu wrote:
> > An ELF file's .note.gnu.property indicates features the executable file
> > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > 
> > With this patch, if an arch needs to setup features from ELF properties,
> > it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
> > arch_setup_property().
> > 
> > For example, for X86_64:
> > 
> > int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> > {
> > 	int r;
> > 	uint32_t property;
> > 
> > 	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> > 			     &property);
> > 	...
> > }
> 
> Although this code works for the simple case, I have some concerns about
> some aspects of the implementation here.  There appear to be some bounds
> checking / buffer overrun issues, and the code seems quite complex.
> 
> Maybe this patch tries too hard to be compatible with toolchains that do
> silly things such as embedding huge notes in an executable, or mixing
> NT_GNU_PROPERTY_TYPE_0 in a single PT_NOTE with a load of junk not
> relevant to the loader.  I wonder whether Linux can dictate what
> interpretation(s) of the ELF specs it is prepared to support, rather than
> trying to support absolutely anything.

To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
logical choice.  And it breaks only a limited set of toolchains.

I will simplify the parser and leave this patch as-is for anyone who wants to
back-port.  Are there any objections or concerns?

Yu-cheng

