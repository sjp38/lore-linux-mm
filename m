Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 49FAC6B0125
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 17:22:25 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so1275816pab.19
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 14:22:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.164])
        by mx.google.com with SMTP id pl8si4018673pbb.344.2013.11.07.14.22.20
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 14:22:21 -0800 (PST)
Date: Thu, 7 Nov 2013 23:21:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
Message-ID: <20131107222144.GC19203@twins.programming.kicks-ass.net>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
 <1383773827.11046.355.camel@schen9-DESK>
 <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
 <CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
 <CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
 <CANN689EgdDQV=srsLELUpiTGOSF0SLUZ=BC2LnMxNrYTv3H=Wg@mail.gmail.com>
 <20131107143139.GT18245@linux.vnet.ibm.com>
 <CANN689FqUSnr=Prum0Kt6+0gr9dWKD8GT9Gbrtiyyg+PTyFkyA@mail.gmail.com>
 <1383858951.11046.399.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383858951.11046.399.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Michel Lespinasse <walken@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, George Spelvin <linux@horizon.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Thu, Nov 07, 2013 at 01:15:51PM -0800, Tim Chen wrote:
> Michel, are you planning to do an implementation of
> load-acquire/store-release functions of various architectures?

A little something like this:
http://marc.info/?l=linux-arch&m=138386254111507

It so happens we were working on that the past week or so due to another
issue ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
