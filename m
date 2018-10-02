Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B21E26B000C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 12:37:35 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p23-v6so2141596wrc.15
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 09:37:35 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id j11-v6si13324827wro.310.2018.10.02.09.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 09:37:34 -0700 (PDT)
Date: Tue, 2 Oct 2018 18:37:36 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 02/27] x86/fpu/xstate: Change some names to
 separate XSAVES system and user states
Message-ID: <20181002163736.GD29601@zn.tnic>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-3-yu-cheng.yu@intel.com>
 <20181002152903.GB29601@zn.tnic>
 <ba13d643c21de8e1e01a8d528457fb5dd82c42aa.camel@intel.com>
 <498c8824-9255-96be-71c2-3ebfa684a9d3@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <498c8824-9255-96be-71c2-3ebfa684a9d3@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Oct 02, 2018 at 09:30:52AM -0700, Dave Hansen wrote:
> > Good point.  However, "system" is more indicative; CET states are per-task and
> > not "Supervisor".  Do we want to go back to "Supervisor" or add comments?
> 
> This is one of those things where the SDM language does not match what
> we use in the kernel.  I think it's fine to call them "system" or
> "kernel" states to make it consistent with our existing in-kernel
> nomenclature.
> 
> I say add comments to clarify what the SDM calls it vs. what we do.

So AFAIU, the difference is that XSAVES is a CPL0 insn. Thus the
supervisor thing, I'd guess.

Now it looks like CET uses XSAVES (from skimming the patchset forward)
but then what our nomenclature is and how it all gets tied together,
needs to be explained somewhere prominent so that we're all on the same
page.

This patch's commit message is not even close. So I'd very much
appreciate a more verbose explanation, even if it repeats itself at
places.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
