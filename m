Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E47E6B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 03:19:23 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d23so3756790wmd.1
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 00:19:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t30sor6895218edt.19.2018.03.05.00.19.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 00:19:21 -0800 (PST)
Date: Mon, 5 Mar 2018 11:19:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: "x86/boot/compressed/64: Prepare trampoline memory" breaks boot
 on Zotac CI-321
Message-ID: <20180305081906.t33mocscprsrlvzp@node.shutemov.name>
References: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
 <CAA42JLZRxCGSsW5FKpH3AjZGbaUyrcRPdVBtMQcc4ZcxKNuDQw@mail.gmail.com>
 <8c6c0f9d-0f47-2fc9-5cb5-6335ef1152cd@gmail.com>
 <20180303100257.hzrqtshcnhzy5spl@gmail.com>
 <f399b62f-984e-c693-81f0-9abe3c49d8f1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f399b62f-984e-c693-81f0-9abe3c49d8f1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiner Kallweit <hkallweit1@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Dexuan-Linux Cui <dexuan.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dexuan Cui <decui@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>

On Sat, Mar 03, 2018 at 12:46:28PM +0100, Heiner Kallweit wrote:
> Am 03.03.2018 um 11:02 schrieb Ingo Molnar:
> > 
> > * Heiner Kallweit <hkallweit1@gmail.com> wrote:
> > 
> >> Am 03.03.2018 um 00:50 schrieb Dexuan-Linux Cui:
> >>> On Fri, Mar 2, 2018 at 12:57 PM, Heiner Kallweit <hkallweit1@gmail.com <mailto:hkallweit1@gmail.com>> wrote:
> >>>
> >>>     Recently my Mini PC Zotac CI-321 started to reboot immediately before
> >>>     anything was written to the console.
> >>>
> >>>     Bisecting lead to b91993a87aff "x86/boot/compressed/64: Prepare
> >>>     trampoline memory" being the change breaking boot.
> >>>
> >>>     If you need any more information, please let me know.
> >>>
> >>>     Rgds, Heiner
> >>>
> >>>
> >>> This may fix the issue: https://lkml.org/lkml/2018/2/13/668
> >>>
> >>> Kirill posted a v2 patchset 3 days ago and I suppose the patchset should include the fix.
> >>>
> >> Thanks for the link. I bisected based on the latest next kernel including
> >> v2 of the patchset (IOW - the potential fix is included already).
> > 
> > Are you sure? b91993a87aff is the old patch-set - which I just removed from -next 
> > and which should thus be gone in the Monday iteration of -next.
> > 
> > I have not merged v2 in -tip yet, did it get applied via some other tree?
> > 
> > Thanks,
> > 
> > 	Ingo
> > 
> I wanted to apply the fix mentioned in the link but found that the statement was movq already.
> Therefore my (most likely false) understanding that it's v2.
> I'll re-test once v2 is out and let you know.

movq fix is unrelated to the problem.

Please check if current linux-next plus this patchset causes a problem for
you:

http://lkml.kernel.org/r/20180227154217.69347-1-kirill.shutemov@linux.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
