Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A697C6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 18:40:56 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s3-v6so18175857plp.21
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 15:40:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j10-v6si19180640pgi.500.2018.07.12.15.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 15:40:55 -0700 (PDT)
Message-ID: <1531435034.2965.15.camel@intel.com>
Subject: Re: [RFC PATCH v2 25/27] x86/cet: Add PTRACE interface for CET
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 12 Jul 2018 15:37:14 -0700
In-Reply-To: <20180712140327.GA7810@gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-26-yu-cheng.yu@intel.com>
	 <20180711102035.GB8574@gmail.com> <1531323638.13297.24.camel@intel.com>
	 <20180712140327.GA7810@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-07-12 at 16:03 +0200, Ingo Molnar wrote:
> * Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> 
> > 
> > > 
> > > > 
> > > > diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
> > > > index e2ee403865eb..ac2bc3a18427 100644
> > > > --- a/arch/x86/kernel/ptrace.c
> > > > +++ b/arch/x86/kernel/ptrace.c
> > > > @@ -49,7 +49,9 @@ enum x86_regset {
> > > > A 	REGSET_IOPERM64 = REGSET_XFP,
> > > > A 	REGSET_XSTATE,
> > > > A 	REGSET_TLS,
> > > > +	REGSET_CET64 = REGSET_TLS,
> > > > A 	REGSET_IOPERM32,
> > > > +	REGSET_CET32,
> > > > A };
> > > Why does REGSET_CET64 alias on REGSET_TLS?
> > In x86_64_regsets[], there is no [REGSET_TLS]. A The core dump code
> > cannot handle holes in the array.
> Is there a fundamental (ABI) reason for that?

What I did was, ran Linux with 'slub_debug', and forced a core dump
(kill -abrt <pid>), then there was a red zone warning in the dmesg.
My feeling is there could be issues in the core dump code. A These
enum's are only local to arch/x86/kernel/ptrace.c and not exported.
I am not aware this is in the ABI.

> 
> > 
> > > 
> > > to "CET" (which is a well-known acronym for "Central European Time"),
> > > not to CFE?
> > > 
> > I don't know if I can change that, will find out.
> So what I'd suggest is something pretty simple: to use CFT/cft in kernel internalA 
> names, except for the Intel feature bit and any MSR enumeration which can be CETA 
> if Intel named it that way, and a short comment explaining the acronym difference.
> 
> Or something like that.

Ok, I will make changes in the next version and probably revise
from that if still not optimal.

Yu-cheng
