Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 179C16B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:09:33 -0500 (EST)
Received: by mail-ve0-f181.google.com with SMTP id oy12so1256209veb.40
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:09:32 -0800 (PST)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id dl10si13126663veb.57.2013.11.22.12.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 12:09:32 -0800 (PST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so1265604veb.19
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:09:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131122200620.GA4138@linux.vnet.ibm.com>
References: <20131121045333.GO4138@linux.vnet.ibm.com>
	<CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
	<20131121225208.GJ4138@linux.vnet.ibm.com>
	<CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
	<20131122040856.GK4138@linux.vnet.ibm.com>
	<CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
	<20131122062314.GN4138@linux.vnet.ibm.com>
	<20131122151600.GA14988@gmail.com>
	<20131122184937.GX4138@linux.vnet.ibm.com>
	<CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
	<20131122200620.GA4138@linux.vnet.ibm.com>
Date: Fri, 22 Nov 2013 12:09:31 -0800
Message-ID: <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 12:06 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> I am sorry, but that is not always correct.  For example, in the contended
> case for Tim Chen's MCS queued locks, the x86 acquisition-side handoff
> code does -not- contain any stores or memory-barrier instructions.

So? In order to get *into* that contention code, you will have to go
through the fast-case code. Which will contain a locked instruction.

So I repeat: a "lock" sequence will always be a memory barrier on x86.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
