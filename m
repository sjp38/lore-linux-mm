Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f43.google.com (mail-vb0-f43.google.com [209.85.212.43])
	by kanga.kvack.org (Postfix) with ESMTP id A74BB6B0036
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 21:11:53 -0500 (EST)
Received: by mail-vb0-f43.google.com with SMTP id q12so1380557vbe.2
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:11:53 -0800 (PST)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id ug9si13585515vcb.32.2013.11.22.18.11.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 18:11:52 -0800 (PST)
Received: by mail-ve0-f179.google.com with SMTP id jw12so1452260veb.38
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:11:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131123013654.GG4138@linux.vnet.ibm.com>
References: <20131122184937.GX4138@linux.vnet.ibm.com>
	<CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
	<20131122200620.GA4138@linux.vnet.ibm.com>
	<CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
	<20131122203738.GC4138@linux.vnet.ibm.com>
	<CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
	<20131122215208.GD4138@linux.vnet.ibm.com>
	<CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
	<20131123002542.GF4138@linux.vnet.ibm.com>
	<CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
	<20131123013654.GG4138@linux.vnet.ibm.com>
Date: Fri, 22 Nov 2013 18:11:52 -0800
Message-ID: <CA+55aFyJRAX4e9H0AFGcPMrBBTmGC6K_iCCS3dc7Mx6ejTmYMA@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 5:36 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> So there is your example.  It really can and does happen.
>
> Again, easy fix.  Just change powerpc's smp_store_release() from lwsync
> to smp_mb().  That fixes the problem and doesn't hurt anyone but powerpc.
>
> OK?

Hmm. Ok

Except now I'm worried it can happen on x86 too because my mental
model was clearly wrong.

x86 does have that extra "Memory ordering obeys causality (memory
ordering respects transitive visibility)." rule, and the example in
the architecture manual (section 8.2.3.6 "Stores Are Transitively
Visible") seems to very much about this, but your particular example
is subtly different, so..

I will have to ruminate on this.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
