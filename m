Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 988EA6B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 05:03:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k2so2048804wmf.9
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 02:03:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r15sor3092220wrc.60.2018.03.03.02.03.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 02:03:01 -0800 (PST)
Date: Sat, 3 Mar 2018 11:02:57 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: "x86/boot/compressed/64: Prepare trampoline memory" breaks boot
 on Zotac CI-321
Message-ID: <20180303100257.hzrqtshcnhzy5spl@gmail.com>
References: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
 <CAA42JLZRxCGSsW5FKpH3AjZGbaUyrcRPdVBtMQcc4ZcxKNuDQw@mail.gmail.com>
 <8c6c0f9d-0f47-2fc9-5cb5-6335ef1152cd@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c6c0f9d-0f47-2fc9-5cb5-6335ef1152cd@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiner Kallweit <hkallweit1@gmail.com>
Cc: Dexuan-Linux Cui <dexuan.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dexuan Cui <decui@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>


* Heiner Kallweit <hkallweit1@gmail.com> wrote:

> Am 03.03.2018 um 00:50 schrieb Dexuan-Linux Cui:
> > On Fri, Mar 2, 2018 at 12:57 PM, Heiner Kallweit <hkallweit1@gmail.com <mailto:hkallweit1@gmail.com>> wrote:
> > 
> >     Recently my Mini PC Zotac CI-321 started to reboot immediately before
> >     anything was written to the console.
> > 
> >     Bisecting lead to b91993a87aff "x86/boot/compressed/64: Prepare
> >     trampoline memory" being the change breaking boot.
> > 
> >     If you need any more information, please let me know.
> > 
> >     Rgds, Heiner
> > 
> > 
> > This may fix the issue: https://lkml.org/lkml/2018/2/13/668
> > 
> > Kirill posted a v2 patchset 3 days ago and I suppose the patchset should include the fix.
> > 
> Thanks for the link. I bisected based on the latest next kernel including
> v2 of the patchset (IOW - the potential fix is included already).

Are you sure? b91993a87aff is the old patch-set - which I just removed from -next 
and which should thus be gone in the Monday iteration of -next.

I have not merged v2 in -tip yet, did it get applied via some other tree?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
