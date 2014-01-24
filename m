Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 897316B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 12:33:13 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id w10so1316270bkz.38
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:33:12 -0800 (PST)
Received: from mail-vb0-x235.google.com (mail-vb0-x235.google.com [2607:f8b0:400c:c02::235])
        by mx.google.com with ESMTPS id b1si3775291bko.349.2014.01.24.09.33.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 09:33:12 -0800 (PST)
Received: by mail-vb0-f53.google.com with SMTP id p17so2043179vbe.12
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:33:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140124170727.GG31570@twins.programming.kicks-ass.net>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
	<1390347382.3138.67.camel@schen9-DESK>
	<20140122183539.GM30183@twins.programming.kicks-ass.net>
	<1390583029.3138.78.camel@schen9-DESK>
	<20140124170727.GG31570@twins.programming.kicks-ass.net>
Date: Fri, 24 Jan 2014 09:33:10 -0800
Message-ID: <CA+55aFzRq8ixqSAm9+iO6-m5agJG0xDt9gZJ_vXpyppePoSxaA@mail.gmail.com>
Subject: Re: [PATCH v9 6/6] MCS Lock: Allow architecture specific asm files to
 be used for contended case
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Jan 24, 2014 at 9:07 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> I have picked up, Ingo generally doesn't merge new patches until after
> -rc1 closes though, with the obvious exception to 'urgent' patches that
> fix problems stemming from the merge window.

Considering how long this has been brewing, I'd argue that we can just
merge it during this merge window unless there are actual problems in
testing.

Sure, there may still be details that need sorting out, but by now I
think they might as well be handled in mainline.

But hey, I'm not going to force it either, so it's up to how comfy you
guys are about the code.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
