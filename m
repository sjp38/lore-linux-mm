Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43AFB6B24DA
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:24:39 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b141-v6so7148925wme.4
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:24:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h7sor17321053wrv.20.2018.11.20.23.24.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 23:24:37 -0800 (PST)
Date: Wed, 21 Nov 2018 08:24:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH v6 01/26] Documentation/x86: Add CET description
Message-ID: <20181121072433.GA56599@gmail.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-2-yu-cheng.yu@intel.com>
 <20181120095253.GA119911@gmail.com>
 <16a0261fbe4b31e2f42b552d6a991a1116d398c2.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16a0261fbe4b31e2f42b552d6a991a1116d398c2.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>


* Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:

> On Tue, 2018-11-20 at 10:52 +0100, Ingo Molnar wrote:
> > * Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > > +X86 Documentation
> > > [...]
> > > +
> > > +At run time, /proc/cpuinfo shows the availability of SHSTK and IBT.
> > 
> > What is the rough expected performance impact of CET on average function 
> > call frequency user applications and the kernel itself?
> 
> I don't have any conclusive numbers yet; but since currently only user-mode
> protection is implemented, I suspect any impact would be most likely to the
> application.  The kernel would spend some small amount of time on the setup of
> CET.

This is horribly vague.

Thanks,

	Ingo
