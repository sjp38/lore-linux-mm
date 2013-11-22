Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f47.google.com (mail-vb0-f47.google.com [209.85.212.47])
	by kanga.kvack.org (Postfix) with ESMTP id 232E06B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 23:26:01 -0500 (EST)
Received: by mail-vb0-f47.google.com with SMTP id x11so501161vbb.6
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 20:26:00 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id td8si11923087vdc.1.2013.11.21.20.25.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 20:26:00 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id ht10so522546vcb.1
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 20:25:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131122040856.GK4138@linux.vnet.ibm.com>
References: <20131120171400.GI4138@linux.vnet.ibm.com>
	<1384973026.11046.465.camel@schen9-DESK>
	<20131120190616.GL4138@linux.vnet.ibm.com>
	<1384979767.11046.489.camel@schen9-DESK>
	<20131120214402.GM4138@linux.vnet.ibm.com>
	<1384991514.11046.504.camel@schen9-DESK>
	<20131121045333.GO4138@linux.vnet.ibm.com>
	<CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
	<20131121225208.GJ4138@linux.vnet.ibm.com>
	<CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
	<20131122040856.GK4138@linux.vnet.ibm.com>
Date: Thu, 21 Nov 2013 20:25:59 -0800
Message-ID: <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 8:08 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> It is not the architecture that matters here, it is just a definition of
> what ordering guarantees the locking primitives provide, independent of
> the architecture.

So we definitely come from very different backgrounds.

I don't care one *whit* about theoretical lock orderings. Not a bit.

I do care deeply about reality, particularly of architectures that
actually matter. To me, a spinlock in some theoretical case is
uninteresting, but a efficient spinlock implementation on a real
architecture is a big deal that matters a lot.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
