Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6752C6B0184
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 17:43:54 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so1243837pdj.38
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 14:43:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id gw3si4465146pac.172.2013.11.07.14.43.51
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 14:43:52 -0800 (PST)
Received: by mail-qe0-f53.google.com with SMTP id cy11so1173068qeb.40
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 14:43:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131107222144.GC19203@twins.programming.kicks-ass.net>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773827.11046.355.camel@schen9-DESK>
	<CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
	<CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
	<CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
	<CANN689EgdDQV=srsLELUpiTGOSF0SLUZ=BC2LnMxNrYTv3H=Wg@mail.gmail.com>
	<20131107143139.GT18245@linux.vnet.ibm.com>
	<CANN689FqUSnr=Prum0Kt6+0gr9dWKD8GT9Gbrtiyyg+PTyFkyA@mail.gmail.com>
	<1383858951.11046.399.camel@schen9-DESK>
	<20131107222144.GC19203@twins.programming.kicks-ass.net>
Date: Thu, 7 Nov 2013 14:43:49 -0800
Message-ID: <CANN689G2H3goDO3KyO5=CzV7RkTukU-B=KsZpLWV_0=pwzZWpw@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, George Spelvin <linux@horizon.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Thu, Nov 7, 2013 at 2:21 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Nov 07, 2013 at 01:15:51PM -0800, Tim Chen wrote:
>> Michel, are you planning to do an implementation of
>> load-acquire/store-release functions of various architectures?
>
> A little something like this:
> http://marc.info/?l=linux-arch&m=138386254111507
>
> It so happens we were working on that the past week or so due to another
> issue ;-)

Haha, awesome, I wasn't aware of this effort.

Tim: my approach would be to provide the acquire/release operations in
arch-specific include files, and have a default implementation using
barriers for arches who don't provide these new ops. That way you make
it work on all arches at once (using the default implementation) and
make it fast on any arch that cares.

>> Or is the approach of arch specific memory barrier for MCS
>> an acceptable one before load-acquire and store-release
>> are available?  Are there any technical issues remaining with
>> the patchset after including including Waiman's arch specific barrier?

I don't want to stand in the way of Waiman's change, and I had
actually taken the same approach with arch-specific barriers when
proposing some queue spinlocks in the past; however I do feel that
this comes back regularly enough that having acquire/release
primitives available would help, hence my proposal.

That said, earlier in the thread Linus said we should probably get all
our ducks in a row before going forward with this, so...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
