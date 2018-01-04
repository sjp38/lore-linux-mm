Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 512246B04C6
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 01:57:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n13so455401wmc.3
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 22:57:29 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m128sor753895wmm.76.2018.01.03.22.57.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 22:57:27 -0800 (PST)
Date: Thu, 4 Jan 2018 07:57:24 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Crashes with KPTI and -rc6
Message-ID: <20180104065724.tzczjnf535pwf7ys@gmail.com>
References: <5b0de7f2-0753-dbfc-e6d3-a5bac3a02a3d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b0de7f2-0753-dbfc-e6d3-a5bac3a02a3d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>


* Laura Abbott <labbott@redhat.com> wrote:

> Hi,
> 
> Fedora got a report via IRC of a double fault with KPTI
> https://paste.fedoraproject.org/paste/SL~of04ZExXP6AN2gcJi7A

I believe this one should be fixed by:

  d7732ba55c4b: x86/pti: Switch to kernel CR3 at early in entry_SYSCALL_compat()

> This is on -rc6 . I saw the one fix posted already which
> I'll pull in but I wanted to report this as a heads up
> in case there are other issues.
> 
> Full tree and configs are at
> https://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git/log/?h=rawhide

Thanks!

Linus's latest upstream:

  00a5ae218d57: Merge branch 'x86-pti-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip

and later kernels includes all fixes for all regressions that were reported so far 
on top of -rc6:

 2fd9c41aea47: x86/process: Define cpu_tss_rw in same section as declaration
 d7732ba55c4b: x86/pti: Switch to kernel CR3 at early in entry_SYSCALL_compat()
 3ffdeb1a02be: x86/dumpstack: Print registers for first stack frame
 a9cdbe72c4e8: x86/dumpstack: Fix partial register dumps
 52994c256df3: x86/pti: Make sure the user/kernel PTEs match
 694d99d40972: x86/cpu, x86/pti: Do not enable PTI on AMD processors
 87faa0d9b43b: x86/pti: Enable PTI by default

PTI fixes can also be independently tracked and pre-merged via:

  git git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git WIP.x86/pti

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
