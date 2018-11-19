Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53C7C6B1CEE
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:18:02 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x13so18393784wro.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 14:18:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a14sor4140402wrm.46.2018.11.19.14.18.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 14:18:00 -0800 (PST)
MIME-Version: 1.0
References: <20181119214934.6174-1-yu-cheng.yu@intel.com> <20181119214934.6174-9-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214934.6174-9-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 19 Nov 2018 14:17:48 -0800
Message-ID: <CALCETrW9ABDotyM020V147+kuizpTRJUAANn-6kUt6-h0Qn0og@mail.gmail.com>
Subject: Re: [RFC PATCH v6 08/11] x86: Insert endbr32/endbr64 to vDSO
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Mon, Nov 19, 2018 at 1:55 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> From: "H.J. Lu" <hjl.tools@gmail.com>
>
> When Intel indirect branch tracking is enabled, functions in vDSO which
> may be called indirectly must have endbr32 or endbr64 as the first
> instruction.  Compiler must support -fcf-protection=branch so that it
> can be used to compile vDSO.
>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> ---
>  arch/x86/entry/vdso/.gitignore        |  4 ++++
>  arch/x86/entry/vdso/Makefile          | 12 +++++++++++-
>  arch/x86/entry/vdso/vdso-layout.lds.S |  1 +
>  3 files changed, 16 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/entry/vdso/.gitignore b/arch/x86/entry/vdso/.gitignore
> index aae8ffdd5880..552941fdfae0 100644
> --- a/arch/x86/entry/vdso/.gitignore
> +++ b/arch/x86/entry/vdso/.gitignore
> @@ -5,3 +5,7 @@ vdso32-sysenter-syms.lds
>  vdso32-int80-syms.lds
>  vdso-image-*.c
>  vdso2c
> +vclock_gettime.S
> +vgetcpu.S
> +vclock_gettime.asm
> +vgetcpu.asm


What's this hunk about?
