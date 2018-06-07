Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56BD66B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:28:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x17-v6so329766pfm.18
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:28:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y125-v6si30464598pfb.284.2018.06.07.09.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 09:28:19 -0700 (PDT)
Received: from mail-wr0-f180.google.com (mail-wr0-f180.google.com [209.85.128.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A640D208AC
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:28:18 +0000 (UTC)
Received: by mail-wr0-f180.google.com with SMTP id w10-v6so10486582wrk.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:28:18 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143705.3531-1-yu-cheng.yu@intel.com> <20180607143705.3531-3-yu-cheng.yu@intel.com>
 <CALCETrWwGCZ+Fbk+O8T6S48teHj60bQQiHQ49=SsKUOpm8VLBA@mail.gmail.com> <1528387137.4636.6.camel@2b52.sc.intel.com>
In-Reply-To: <1528387137.4636.6.camel@2b52.sc.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 09:28:05 -0700
Message-ID: <CALCETrWEeBbhGgJ2rVMAQGOK3BUuRSCWzuhmpO=WrmwO85Tnaw@mail.gmail.com>
Subject: Re: [PATCH 2/9] x86/cet: Add Kconfig option for user-mode shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Andrew Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 9:02 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> On Thu, 2018-06-07 at 08:47 -0700, Andy Lutomirski wrote:
> > On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > >
> > > Introduce Kconfig option X86_INTEL_SHADOW_STACK_USER.
> > >
> > > An application has shadow stack protection when all the following are
> > > true:
> > >
> > >   (1) The kernel has X86_INTEL_SHADOW_STACK_USER enabled,
> > >   (2) The running processor supports the shadow stack,
> > >   (3) The application is built with shadow stack enabled tools & libs
> > >       and, and at runtime, all dependent shared libs can support shadow
> > >       stack.
> > >
> > > If this kernel config option is enabled, but (2) or (3) above is not
> > > true, the application runs without the shadow stack protection.
> > > Existing legacy applications will continue to work without the shadow
> > > stack protection.
> > >
> > > The user-mode shadow stack protection is only implemented for the
> > > 64-bit kernel.  Thirty-two bit applications are supported under the
> > > compatibility mode.
> > >
> >
> > The 64-bit only part seems entirely reasonable.  So please make the
> > code 64-bit only :)
>
> Yes, I will remove changes in "arch/x86/entry/entry32.S".
> We still want to support x32/ia32 in the 64-bit kernel, right?
>

Yes, I think.  But that's not in entry_32.S


>
