Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A98E56B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:07:54 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b26-v6so4051736lfa.6
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:07:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23-v6sor925841lfy.56.2018.06.08.05.07.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 05:07:52 -0700 (PDT)
Date: Fri, 8 Jun 2018 15:07:50 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
Message-ID: <20180608120750.GB2525@uranus>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-4-yu-cheng.yu@intel.com>
 <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
 <20180607200714.GA2525@uranus>
 <CALCETrXAoPsHK49c1Dpa8N0ccsxjwnVOTktKVaY++xjHxdmUzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXAoPsHK49c1Dpa8N0ccsxjwnVOTktKVaY++xjHxdmUzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Florian Weimer <fweimer@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 07, 2018 at 01:57:03PM -0700, Andy Lutomirski wrote:
...
> >
> > I didn't read the whole series of patches in details
> > yet, hopefully will be able tomorrow. Thanks Andy for
> > CC'ing!
> 
> We have uc_flags.  It might be useful to carve out some of the flag
> space (24 bits?) to indicate something like the *size* of sigcontext
> and teach the kernel that new sigcontext fields should only be parsed
> on sigreturn() if the size is large enough.

Yes, this should do the trick.
