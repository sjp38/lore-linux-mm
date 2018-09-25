Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4538E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 12:34:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i68-v6so12893076pfb.9
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 09:34:31 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i64-v6si2641645pfb.314.2018.09.25.09.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 09:34:30 -0700 (PDT)
Message-ID: <309a30584a56babbd4d25199f71b786442300c1e.camel@intel.com>
Subject: Re: [RFC PATCH v4 01/27] x86/cpufeatures: Add CPUIDs for
 Control-flow Enforcement Technology (CET)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 25 Sep 2018 09:29:51 -0700
In-Reply-To: <20180925162705.GB30146@hirez.programming.kicks-ass.net>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-2-yu-cheng.yu@intel.com>
	 <20180925162705.GB30146@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-09-25 at 18:27 +0200, Peter Zijlstra wrote:
> On Fri, Sep 21, 2018 at 08:03:25AM -0700, Yu-cheng Yu wrote:
> 
> > diff --git a/arch/x86/kernel/cpu/scattered.c
> > b/arch/x86/kernel/cpu/scattered.c
> > index 772c219b6889..63cbb4d9938e 100644
> > --- a/arch/x86/kernel/cpu/scattered.c
> > +++ b/arch/x86/kernel/cpu/scattered.c
> > @@ -21,6 +21,7 @@ struct cpuid_bit {
> >  static const struct cpuid_bit cpuid_bits[] = {
> >  	{ X86_FEATURE_APERFMPERF,       CPUID_ECX,  0, 0x00000006, 0 },
> >  	{ X86_FEATURE_EPB,		CPUID_ECX,  3, 0x00000006, 0 },
> > +	{ X86_FEATURE_IBT,		CPUID_EDX, 20, 0x00000007, 0},
> 
>                                                                    ^^
> missing white space at the end there.

I will fix it.  Thanks!
