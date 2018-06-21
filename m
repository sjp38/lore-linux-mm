Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9EA6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 19:10:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 69-v6so1814241pgg.0
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 16:10:57 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j12-v6si4741378pgq.312.2018.06.21.16.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 16:10:51 -0700 (PDT)
Message-ID: <1529622448.30393.22.camel@intel.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 21 Jun 2018 16:07:28 -0700
In-Reply-To: <13E3C29A-3295-4A7F-90EC-A84CF34F3E1A@amacapital.net>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-7-yu-cheng.yu@intel.com>
	 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
	 <1528403417.5265.35.camel@2b52.sc.intel.com>
	 <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
	 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
	 <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de>
	 <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
	 <CALCETrXO8R+RQPhJFk4oiA4PF77OgSS2Yro_POXQj1zvdLo61A@mail.gmail.com>
	 <CAMe9rOpLxPussn7gKvn0GgbOB4f5W+DKOGipe_8NMam+Afd+RA@mail.gmail.com>
	 <CALCETrWmGRkQvsUgRaj+j0CP4beKys+TT5aDR5+18nuphwr+Cw@mail.gmail.com>
	 <CAMe9rOpzcCdje=bUVs+C1WrY6GuwA-8AUFVLOG325LGz7KHJxw@mail.gmail.com>
	 <alpine.DEB.2.21.1806122046520.1592@nanos.tec.linutronix.de>
	 <CAMe9rOrGjJf0aMnUjAP38MqvOiW3=iXGQjcUT3O=f9pE85hXaw@mail.gmail.com>
	 <CALCETrVsh5t-V1Sm88LsZE_+DS0GE_bMWbcoX3SjD6GnrB08Pw@mail.gmail.com>
	 <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
	 <569B4719-6283-4575-A16E-D0A78D280F4E@amacapital.net>
	 <CAGXu5jJNgu4bW_Zthqjfpe9gLxK0zxG8QFEqqK+pJNebz6tUaw@mail.gmail.com>
	 <1529427588.23068.7.camel@intel.com>
	 <CAGXu5jJ4ivrvi-kG0iY=4C0mQQXBDXwPdfY36Dk+JqOpX19n0w@mail.gmail.com>
	 <0AF8B71E-B6CC-42DE-B95C-93896196C3D7@amacapital.net>
	 <CAGXu5jLEMy_T_5OtXLT+pUCt=Nk53nBbuRvrUgJBhq-4RZ=yCA@mail.gmail.com>
	 <446EB18D-EF06-4A04-AF62-E72C68D96A84@amacapital.net>
	 <1529447937.27370.33.camel@intel.com>
	 <13E3C29A-3295-4A7F-90EC-A84CF34F3E1A@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com, Florian Weimer <fweimer@redhat.com>

On Tue, 2018-06-19 at 17:50 -0700, Andy Lutomirski wrote:
> 
> > 
> > On Jun 19, 2018, at 3:38 PM, Yu-cheng Yu <yu-cheng.yu@intel.com>
> > wrote:
> > 
> > On Tue, 2018-06-19 at 13:47 -0700, Andy Lutomirski wrote:
> > > 
> > > > 
> > > > 
> > > > On Jun 19, 2018, at 1:12 PM, Kees Cook <keescook@chromium.org>
> > > > wrote:
> > > > 
> > > > > 
> > > > > 
> > > > > On Tue, Jun 19, 2018 at 10:20 AM, Andy Lutomirski <luto@amaca
> > > > > pita
> > > > > l.net> wrote:
> > > > > 
> > > > > > 
> > > > > > 
> > > > > > On Jun 19, 2018, at 10:07 AM, Kees Cook <keescook@chromium.
> > > > > > org>
> > > > > > wrote:
> > > > > > 
> > > > > > Does it provide anything beyond what PR_DUMPABLE does?
> > > > > What do you mean?
> > > > I was just going by the name of it. I wasn't sure what "ptrace
> > > > CET
> > > > lock" meant, so I was trying to understand if it was another
> > > > "you
> > > > can't ptrace me" toggle, and if so, wouldn't it be redundant
> > > > with
> > > > PR_SET_DUMPABLE = 0, etc.
> > > > 
> > > No, other way around. The valid CET states are on/unlocked,
> > > off/unlocked, on/locked, off/locked. arch_prctl can freely the
> > > state
> > > unless locked. ptrace can change it no matter what.A A The lock is
> > > to
> > > prevent the existence of a gadget to disable CET (unless the
> > > gadget
> > > involves ptrace, but I dona??t think thata??s a real concern).
> > We have the arch_prctl now and only need to add ptrace lock/unlock.
> > 
> > Back to the dlopen() "relaxed" mode. Would the following work?
> > 
> > If the lib being loaded does not use setjmp/getcontext families
> > (the
> > loader knows?), then the loader leaves shstk on.A A 
> Will that actually work?A A Are there libs that do something like
> longjmp without actually using the glibc longjmp routine?A A What about
> compilers that statically match a throw to a catch and try to return
> through several frames at once?
> 

The compiler throw/catch is already handled similarly to how longjmp is
handled.

To summarize the dlopen() situation,

----
(1) We don't want to fall back like the following. A One reason is
turning off SHSTK for threads is tricky.

if ((dlopen() a legacy library) && (cet_policy==relaxed)) {
	/*
	A * We don't care if the library will actually fault;
	A * just turn off CET protection now.
	A */
	Turn off CET;
}

(2) We cannot predict what version of a library will be dlopen'ed, and
cannot turn off CET reliably from the beginning of an application.
----

Can we mandate a signal handler (to turn off CET) when ((dlopen is used
) && (cet_policy==relaxed))?

> > 
> > Otherwise, if the
> > system-wide setting is "relaxed", the loader turns off shstk and
> > issues
> > a warning.A A In addition, if (dlopen == relaxed), then cet is not
> > locked
> > in any time.
> > 
> > The system-wide setting (somewhere in /etc?) can be:
> > 
> > A A A dlopen=force|relaxed /* controls dlopen of non-cet libs */
> > A A A exec=force|relaxed /* controls exec of non-cet apps */
> > 
> > 
> Why do we need a whole new mechanism here?A A Cana??t all this use
> regular glibc tunables?

Ok, got it.

Yu-cheng
