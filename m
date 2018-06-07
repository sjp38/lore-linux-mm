Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5D256B026C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:02:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w1-v6so3664355pgr.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:02:09 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id l138-v6si13522754pfd.355.2018.06.07.09.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 09:02:08 -0700 (PDT)
Message-ID: <1528387137.4636.6.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 2/9] x86/cet: Add Kconfig option for user-mode shadow
 stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 08:58:57 -0700
In-Reply-To: <CALCETrWwGCZ+Fbk+O8T6S48teHj60bQQiHQ49=SsKUOpm8VLBA@mail.gmail.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
	 <20180607143705.3531-3-yu-cheng.yu@intel.com>
	 <CALCETrWwGCZ+Fbk+O8T6S48teHj60bQQiHQ49=SsKUOpm8VLBA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 08:47 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > Introduce Kconfig option X86_INTEL_SHADOW_STACK_USER.
> >
> > An application has shadow stack protection when all the following are
> > true:
> >
> >   (1) The kernel has X86_INTEL_SHADOW_STACK_USER enabled,
> >   (2) The running processor supports the shadow stack,
> >   (3) The application is built with shadow stack enabled tools & libs
> >       and, and at runtime, all dependent shared libs can support shadow
> >       stack.
> >
> > If this kernel config option is enabled, but (2) or (3) above is not
> > true, the application runs without the shadow stack protection.
> > Existing legacy applications will continue to work without the shadow
> > stack protection.
> >
> > The user-mode shadow stack protection is only implemented for the
> > 64-bit kernel.  Thirty-two bit applications are supported under the
> > compatibility mode.
> >
> 
> The 64-bit only part seems entirely reasonable.  So please make the
> code 64-bit only :)

Yes, I will remove changes in "arch/x86/entry/entry32.S".
We still want to support x32/ia32 in the 64-bit kernel, right?
