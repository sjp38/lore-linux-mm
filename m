Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB8BBC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:55:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAF1E22DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:55:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAF1E22DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 538F76B02CD; Wed, 21 Aug 2019 10:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C1B46B02CE; Wed, 21 Aug 2019 10:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 388BD6B02CF; Wed, 21 Aug 2019 10:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1C16B02CD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:55:42 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B072CAF74
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:55:41 +0000 (UTC)
X-FDA: 75846734082.09.bit99_31965a048f862
X-HE-Tag: bit99_31965a048f862
X-Filterd-Recvd-Size: 3255
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:55:40 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Aug 2019 07:55:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,412,1559545200"; 
   d="scan'208";a="186252384"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by FMSMGA003.fm.intel.com with ESMTP; 21 Aug 2019 07:55:38 -0700
Message-ID: <8d2e5bc4496075032393ff9ae81a26f7fbc711e6.camel@intel.com>
Subject: Re: [PATCH v8 02/27] x86/cpufeatures: Add CET CPU feature flags for
 Control-flow Enforcement Technology (CET)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Wed, 21 Aug 2019 07:46:32 -0700
In-Reply-To: <20190821102052.GD6752@zn.tnic>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-3-yu-cheng.yu@intel.com>
	 <20190821102052.GD6752@zn.tnic>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-21 at 12:20 +0200, Borislav Petkov wrote:
> On Tue, Aug 13, 2019 at 01:52:00PM -0700, Yu-cheng Yu wrote:
> > Add CPU feature flags for Control-flow Enforcement Technology (CET).
> > 
> > [...]
> > diff --git a/arch/x86/kernel/cpu/cpuid-deps.c b/arch/x86/kernel/cpu/cpuid-
> > deps.c
> > index b5353244749b..9bf35f081080 100644
> > --- a/arch/x86/kernel/cpu/cpuid-deps.c
> > +++ b/arch/x86/kernel/cpu/cpuid-deps.c
> > @@ -68,6 +68,8 @@ static const struct cpuid_dep cpuid_deps[] = {
> >  	{ X86_FEATURE_CQM_MBM_TOTAL,	X86_FEATURE_CQM_LLC   },
> >  	{ X86_FEATURE_CQM_MBM_LOCAL,	X86_FEATURE_CQM_LLC   },
> >  	{ X86_FEATURE_AVX512_BF16,	X86_FEATURE_AVX512VL  },
> > +	{ X86_FEATURE_SHSTK,		X86_FEATURE_XSAVES    },
> > +	{ X86_FEATURE_IBT,		X86_FEATURE_XSAVES    },
> 
> This hunk needs re-tabbing after:
> 
> 1e0c08e3034d ("cpu/cpuid-deps: Add a tab to cpuid dependent features")

Thanks, I will fix it.

Yu-cheng

