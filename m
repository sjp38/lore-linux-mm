Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id AC7FD6B0036
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 07:38:41 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id d13so3129559wiw.6
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:38:41 -0800 (PST)
Received: from mail-ea0-x234.google.com (mail-ea0-x234.google.com [2a00:1450:4013:c01::234])
        by mx.google.com with ESMTPS id dw10si798446wib.17.2014.01.20.04.38.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 04:38:40 -0800 (PST)
Received: by mail-ea0-f180.google.com with SMTP id f15so3076296eak.39
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:38:40 -0800 (PST)
Date: Mon, 20 Jan 2014 13:38:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v7 6/6] MCS Lock: add Kconfig entries to allow
 arch-specific hooks
Message-ID: <20140120123837.GA11173@gmail.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917316.3138.16.camel@schen9-DESK>
 <20140120123030.GE31570@twins.programming.kicks-ass.net>
 <CAMuHMdXmTOAqpaCPY=TT=dD4JPJ2Sz094Yavvh8LqFXheX3UpA@mail.gmail.com>
 <20140120123655.GF30183@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140120123655.GF30183@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Jan 20, 2014 at 01:35:16PM +0100, Geert Uytterhoeven wrote:
> > On Mon, Jan 20, 2014 at 1:30 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > Then again, people seem to whinge if you don't keep these Kbuild files
> > > sorted, but manually sorting 29 files is just not something I like to
> > > do.
> > 
> > So you're offloading this to Stephen, who will see merge conflicts and will do
> > it anyway, delaying the next -next release by a few minutes?
> 
> Nah, I was hoping to offload to Tim :-)
> 
> Also, we really need a script to do this.

Or at least a script to check it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
