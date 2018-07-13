Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 106A76B000D
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:34:03 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t10-v6so5645197wre.19
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 06:34:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k2-v6sor11615543wrg.77.2018.07.13.06.34.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 06:34:01 -0700 (PDT)
Date: Fri, 13 Jul 2018 15:33:58 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH v2 25/27] x86/cet: Add PTRACE interface for CET
Message-ID: <20180713133357.GB13602@gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-26-yu-cheng.yu@intel.com>
 <20180711102035.GB8574@gmail.com>
 <1531323638.13297.24.camel@intel.com>
 <20180712140327.GA7810@gmail.com>
 <20180713062804.GA6905@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180713062804.GA6905@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>


* Pavel Machek <pavel@ucw.cz> wrote:

> 
> > > > to "CET" (which is a well-known acronym for "Central European Time"),
> > > > not to CFE?
> > > > 
> > > 
> > > I don't know if I can change that, will find out.
> > 
> > So what I'd suggest is something pretty simple: to use CFT/cft in kernel internal 
> > names, except for the Intel feature bit and any MSR enumeration which can be CET 
> > if Intel named it that way, and a short comment explaining the acronym difference.
> > 
> > Or something like that.
> 
> Actually, I don't think CFT is much better -- there's limited number
> of TLAs (*). "ENFORCE_FLOW"? "FLOWE"? "EFLOW"?

Erm, I wanted to say 'CFE', i.e. the abbreviation of 'Control Flow Enforcement'.

But I guess I can live with CET as well ...

Thanks,

	Ingo
