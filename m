Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0793B6B0038
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:02:15 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so1349067pad.10
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:02:15 -0800 (PST)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id sn7si14701568pab.22.2013.11.20.09.02.13
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:02:14 -0800 (PST)
Date: Wed, 20 Nov 2013 17:00:17 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 0/5] MCS Lock: MCS lock code cleanup and optimizations
Message-ID: <20131120170017.GI19352@mudshark.cambridge.arm.com>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911446.11046.450.camel@schen9-DESK>
 <20131120101957.GA19352@mudshark.cambridge.arm.com>
 <20131120125023.GC4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131120125023.GC4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 20, 2013 at 12:50:23PM +0000, Paul E. McKenney wrote:
> On Wed, Nov 20, 2013 at 10:19:57AM +0000, Will Deacon wrote:
> > On Wed, Nov 20, 2013 at 01:37:26AM +0000, Tim Chen wrote:
> > > Will, do you want to take a crack at adding implementation for ARM
> > > with wfe instruction?
> > 
> > Sure, I'll have a go this week. Thanks for keeping that as a consideration!
> > 
> > As an aside: what are you using to test this code, so that I can make sure I
> > don't break it?
> 
> +1 to that!  In fact, it would be nice to have the test code in-tree,
> especially if it can test a wide variety of locks.  (/me needs to look
> at what test code for locks might already be in tree, for that matter...)

Well, in the absence of those tests, I've implemented something that I think
will work for ARM and could be easily extended to arm64.

Tim: I reverted your final patch and went with Paul's suggestion just to
look into the contended case. I'm also not sure about adding
asm/mcs_spinlock.h. This stuff might be better in asm/spinlock.h, which
already exists and contains both spinlocks and rwlocks. Depends on how much
people dislike the Kconfig symbol + conditional #include.

Anyway, patches below. I included the ARM bits for reference, but please
don't include them in your series!

Cheers,

Will

--->8
