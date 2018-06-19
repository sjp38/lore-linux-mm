Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70BBC6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 18:42:19 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bf1-v6so597094plb.2
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 15:42:19 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o3-v6si784057pld.50.2018.06.19.15.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 15:42:17 -0700 (PDT)
Message-ID: <1529447937.27370.33.camel@intel.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 19 Jun 2018 15:38:57 -0700
In-Reply-To: <446EB18D-EF06-4A04-AF62-E72C68D96A84@amacapital.net>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@kernel.org>, "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com, Florian Weimer <fweimer@redhat.com>

On Tue, 2018-06-19 at 13:47 -0700, Andy Lutomirski wrote:
> > 
> > On Jun 19, 2018, at 1:12 PM, Kees Cook <keescook@chromium.org>
> > wrote:
> > 
> > > 
> > > On Tue, Jun 19, 2018 at 10:20 AM, Andy Lutomirski <luto@amacapita
> > > l.net> wrote:
> > > 
> > > > 
> > > > On Jun 19, 2018, at 10:07 AM, Kees Cook <keescook@chromium.org>
> > > > wrote:
> > > > 
> > > > Does it provide anything beyond what PR_DUMPABLE does?
> > > What do you mean?
> > I was just going by the name of it. I wasn't sure what "ptrace CET
> > lock" meant, so I was trying to understand if it was another "you
> > can't ptrace me" toggle, and if so, wouldn't it be redundant with
> > PR_SET_DUMPABLE = 0, etc.
> > 
> No, other way around. The valid CET states are on/unlocked,
> off/unlocked, on/locked, off/locked. arch_prctl can freely the state
> unless locked. ptrace can change it no matter what.A A The lock is to
> prevent the existence of a gadget to disable CET (unless the gadget
> involves ptrace, but I dona??t think thata??s a real concern).

We have the arch_prctl now and only need to add ptrace lock/unlock.

Back to the dlopen() "relaxed" mode. Would the following work?

If the lib being loaded does not use setjmp/getcontext families (the
loader knows?), then the loader leaves shstk on. A Otherwise, if the
system-wide setting is "relaxed", the loader turns off shstk and issues
a warning. A In addition, if (dlopen == relaxed), then cet is not locked
in any time.

The system-wide setting (somewhere in /etc?) can be:

	dlopen=force|relaxed /* controls dlopen of non-cet libs */
	exec=force|relaxed /* controls exec of non-cet apps */

--
Yu-cheng
