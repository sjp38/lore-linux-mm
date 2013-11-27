Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f50.google.com (mail-vb0-f50.google.com [209.85.212.50])
	by kanga.kvack.org (Postfix) with ESMTP id E917A6B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 11:58:36 -0500 (EST)
Received: by mail-vb0-f50.google.com with SMTP id 10so5076794vbe.37
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 08:58:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c8si21384111vcq.63.2013.11.27.08.58.34
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 08:58:35 -0800 (PST)
Date: Wed, 27 Nov 2013 17:58:40 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131127165840.GA26138@redhat.com>
References: <20131122155835.GR3866@twins.programming.kicks-ass.net> <20131122182632.GW4138@linux.vnet.ibm.com> <20131122185107.GJ4971@laptop.programming.kicks-ass.net> <20131125173540.GK3694@twins.programming.kicks-ass.net> <20131125180250.GR4138@linux.vnet.ibm.com> <20131125182715.GG10022@twins.programming.kicks-ass.net> <20131125235252.GA4138@linux.vnet.ibm.com> <20131126095945.GI10022@twins.programming.kicks-ass.net> <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com> <20131126192133.GF789@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131126192133.GF789@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On 11/26, Peter Zijlstra wrote:
>
> On Tue, Nov 26, 2013 at 11:00:50AM -0800, Linus Torvalds wrote:
>
> > IOW, where do we really care about the "unlock+lock" is a memory
> > barrier? And could we make those places explicit, and then do
> > something similar to the above to them?
>
> So I don't know :-(
>
> I do know myself and Oleg have often talked about it, and I'm fairly
> sure we must have used it at some point.

No... I can't recall any particular place which explicitely relies
on "unlock+lock => mb().

(although I know the out-of-tree example which can be ignored ;)

I can only recall that this was mentioned in the context like
"no, the lack of mb() can't explain the problem because we have
unlock+lock".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
