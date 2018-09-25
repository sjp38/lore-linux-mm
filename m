Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEA038E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:28:33 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id i189-v6so1183551pge.6
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 10:28:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v18-v6si1035977pgi.421.2018.09.25.10.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 10:28:32 -0700 (PDT)
Message-ID: <57ab71005afeaeb195a49c72ae8c76481023130f.camel@intel.com>
Subject: Re: [RFC PATCH v4 03/27] x86/fpu/xstate: Enable XSAVES system states
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 25 Sep 2018 10:23:57 -0700
In-Reply-To: <20180925170355.GD30146@hirez.programming.kicks-ass.net>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-4-yu-cheng.yu@intel.com>
	 <20180925170355.GD30146@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-09-25 at 19:03 +0200, Peter Zijlstra wrote:
> On Fri, Sep 21, 2018 at 08:03:27AM -0700, Yu-cheng Yu wrote:
> > diff --git a/arch/x86/kernel/fpu/core.c b/arch/x86/kernel/fpu/core.c
> > index 4bd56079048f..9f51b0e1da25 100644
> > --- a/arch/x86/kernel/fpu/core.c
> > +++ b/arch/x86/kernel/fpu/core.c
> > @@ -365,8 +365,13 @@ void fpu__drop(struct fpu *fpu)
> >   */
> >  static inline void copy_init_user_fpstate_to_fpregs(void)
> >  {
> > +	/*
> > +	 * Only XSAVES user states are copied.
> > +	 * System states are preserved.
> > +	 */
> >  	if (use_xsave())
> > -		copy_kernel_to_xregs(&init_fpstate.xsave, -1);
> > +		copy_kernel_to_xregs(&init_fpstate.xsave,
> > +				     xfeatures_mask_user);
> 
> By my counting, that doesn't qualify for a line-break, it hits 80.
> 
> If you were to do this line-break, coding style would have you liberally
> sprinkle {} around.

Ok, will fix it.
