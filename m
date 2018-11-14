Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2F226B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:24:56 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id z22-v6so13304372pfi.0
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 12:24:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s13si619026pgh.583.2018.11.14.12.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 12:24:55 -0800 (PST)
Message-ID: <307b6162b0270871e664ca88a96b4ea0d1b3f65b.camel@intel.com>
Subject: Re: [PATCH v5 06/27] x86/cet: Control protection exception handler
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 14 Nov 2018 12:19:42 -0800
In-Reply-To: <20181114184436.GK13926@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-7-yu-cheng.yu@intel.com>
	 <20181114184436.GK13926@zn.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-11-14 at 19:44 +0100, Borislav Petkov wrote:
> That subject needs a verb:
> 
> Subject: [PATCH v5 06/27] x86/cet: Add control protection exception handler
> 
> On Thu, Oct 11, 2018 at 08:15:02AM -0700, Yu-cheng Yu wrote:
> > A control protection exception is triggered when a control flow transfer
> > attempt violated shadow stack or indirect branch tracking constraints.
> > For example, the return address for a RET instruction differs from the
> > safe copy on the shadow stack; or a JMP instruction arrives at a non-
> > ENDBR instruction.
> > 
> > The control protection exception handler works in a similar way as the
> > general protection fault handler.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  arch/x86/entry/entry_64.S          |  2 +-
> >  arch/x86/include/asm/traps.h       |  3 ++
> >  arch/x86/kernel/idt.c              |  4 ++
> >  arch/x86/kernel/signal_compat.c    |  2 +-
> >  arch/x86/kernel/traps.c            | 64 ++++++++++++++++++++++++++++++
> >  include/uapi/asm-generic/siginfo.h |  3 +-
> >  6 files changed, 75 insertions(+), 3 deletions(-)
> 
> A *lot* of style problems here. Please use checkpatch and then common
> sense to check your patches before sending. All those below are valid,
> AFAICT:
> 
> WARNING: function definition argument 'struct pt_regs *' should also have an
> identifier name
> #76: FILE: arch/x86/include/asm/traps.h:81:
> +dotraplinkage void do_control_protection(struct pt_regs *, long);
> 
> WARNING: function definition argument 'long' should also have an identifier
> name
> #76: FILE: arch/x86/include/asm/traps.h:81:
> +dotraplinkage void do_control_protection(struct pt_regs *, long);

Yes, I was not sure if the addition should follow the existing style (which does
not have identifier names).  What do you think is right?

Thanks,
Yu-cheng
