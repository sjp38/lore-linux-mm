Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25D106B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:16:44 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u36so12740319wrf.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:16:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x91sor3818920edc.36.2018.03.06.00.16.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:16:42 -0800 (PST)
Date: Tue, 6 Mar 2018 11:16:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: "x86/boot/compressed/64: Prepare trampoline memory" breaks boot
 on Zotac CI-321
Message-ID: <20180306081626.aoj3gh3wqls6n6k4@node.shutemov.name>
References: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
 <CAA42JLZRxCGSsW5FKpH3AjZGbaUyrcRPdVBtMQcc4ZcxKNuDQw@mail.gmail.com>
 <8c6c0f9d-0f47-2fc9-5cb5-6335ef1152cd@gmail.com>
 <20180303100257.hzrqtshcnhzy5spl@gmail.com>
 <f399b62f-984e-c693-81f0-9abe3c49d8f1@gmail.com>
 <20180305081906.t33mocscprsrlvzp@node.shutemov.name>
 <a2898317-18d0-d542-a767-ee9cf256ced9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a2898317-18d0-d542-a767-ee9cf256ced9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiner Kallweit <hkallweit1@gmail.com>, Ingo Molnar <mingo@kernel.org>
Cc: Dexuan-Linux Cui <dexuan.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dexuan Cui <decui@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Mar 05, 2018 at 07:57:06PM +0100, Heiner Kallweit wrote:
> Am 05.03.2018 um 09:19 schrieb Kirill A. Shutemov:
> > On Sat, Mar 03, 2018 at 12:46:28PM +0100, Heiner Kallweit wrote:
> >> I wanted to apply the fix mentioned in the link but found that the statement was movq already.
> >> Therefore my (most likely false) understanding that it's v2.
> >> I'll re-test once v2 is out and let you know.
> > 
> > movq fix is unrelated to the problem.
> > 
> > Please check if current linux-next plus this patchset causes a problem for
> > you:
> > 
> > http://lkml.kernel.org/r/20180227154217.69347-1-kirill.shutemov@linux.intel.com
> > 
> 
> linux-next from today boots fine with the patchset applied.

Thanks for testing!

Ingo, is there anything else I need to do for the patchset to be applied?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
