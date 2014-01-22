Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id AF4936B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:52:36 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so589891wgg.34
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 09:52:36 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id hq3si7421266wib.38.2014.01.22.09.52.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jan 2014 09:52:35 -0800 (PST)
Date: Wed, 22 Jan 2014 18:51:52 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v9 5/6] MCS Lock: Order the header files in Kbuild of
 each architecture in alphabetical order
Message-ID: <20140122175152.GT31570@twins.programming.kicks-ass.net>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
 <1390347376.3138.66.camel@schen9-DESK>
 <20140122130818.GP31570@twins.programming.kicks-ass.net>
 <1390412468.3138.69.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390412468.3138.69.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>, sfr@canb.auug.org.au

On Wed, Jan 22, 2014 at 09:41:08AM -0800, Tim Chen wrote:
> On Wed, 2014-01-22 at 14:08 +0100, Peter Zijlstra wrote:
> > On Tue, Jan 21, 2014 at 03:36:16PM -0800, Tim Chen wrote:
> > > From: Peter Zijlstra <peterz@infradead.org>
> > > 
> > > We perform a clean up of the Kbuid files in each architecture.
> > > We order the files in each Kbuild in alphabetical order
> > > by running the below script on each Kbuild file:
> > > 
> > > gawk '/^generic-y/ {
> > >         i = 3;
> > >         do {
> > >                 for (; i<=NF; i++) {
> > >                         if ($i == "\\") {
> > >                                 getline;
> > >                                 i=1;
> > >                                 continue;
> > >                         }
> > >                         if ($i != "")
> > >                                 hdr[$i] = $i;
> > >                 }
> > >                 break;
> > >         } while (1);
> > >         next;
> > > }
> > > END {
> > >         n = asort(hdr);
> > >         for (i=1; i<=n; i++)
> > >                 print "generic-y += " hdr[i];
> > > }'
> > > 
> > 
> > I'll probably have to regenerate this patch once the merge window is
> > done, but that's no biggie.
> > 
> > sfr, you might want to keep this script handy and distribute to others
> > who are lazy and don't want to sort by hand.
> > 
> > I suppose running it requires a little something like:
> > 
> > for i in arch/*/include/asm/Kbuild
> > do
> > 	cat $i | gawk .... > ${i}.sorted;
> > 	mv ${i}.sorted $i;
> > done
> 
> Peter, if this patch and the next one that adds mcs_spinlock.h to
> Kbuild looks okay, can you add your signed-off?  Thanks.

Script did that when I queued the lot :-) Just haven't gotten around to
building the entire thing yet -- been busy huntin' wabbits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
