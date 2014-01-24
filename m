Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EFF4D6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 12:38:59 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x13so3253905wgg.3
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:38:59 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id gq3si995177wjc.3.2014.01.24.09.38.58
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 09:38:59 -0800 (PST)
Date: Fri, 24 Jan 2014 17:37:13 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 6/6] MCS Lock: Allow architecture specific asm files
 to be used for contended case
Message-ID: <20140124173713.GO31040@mudshark.cambridge.arm.com>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
 <1390347382.3138.67.camel@schen9-DESK>
 <20140122183539.GM30183@twins.programming.kicks-ass.net>
 <1390583029.3138.78.camel@schen9-DESK>
 <20140124170727.GG31570@twins.programming.kicks-ass.net>
 <CA+55aFzRq8ixqSAm9+iO6-m5agJG0xDt9gZJ_vXpyppePoSxaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzRq8ixqSAm9+iO6-m5agJG0xDt9gZJ_vXpyppePoSxaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Jan 24, 2014 at 05:33:10PM +0000, Linus Torvalds wrote:
> On Fri, Jan 24, 2014 at 9:07 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > I have picked up, Ingo generally doesn't merge new patches until after
> > -rc1 closes though, with the obvious exception to 'urgent' patches that
> > fix problems stemming from the merge window.
> 
> Considering how long this has been brewing, I'd argue that we can just
> merge it during this merge window unless there are actual problems in
> testing.
> 
> Sure, there may still be details that need sorting out, but by now I
> think they might as well be handled in mainline.
> 
> But hey, I'm not going to force it either, so it's up to how comfy you
> guys are about the code.

Suits me, then I can get the ARM parts in for 3.15.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
