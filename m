Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 071016B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 20:05:46 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md4so948117pbc.35
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 17:05:46 -0700 (PDT)
Date: Wed, 5 Jun 2013 09:05:03 +0900 (PWT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: TLB and PTE coherency during munmap
In-Reply-To: <20130604095258.GL8923@twins.programming.kicks-ass.net>
Message-ID: <alpine.LFD.2.03.1306050904160.28129@pixel.linux-foundation.org>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com> <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com> <51A45861.1010008@gmail.com> <20130529122728.GA27176@twins.programming.kicks-ass.net> <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net> <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com> <20130603090501.GI5910@twins.programming.kicks-ass.net> <20130604095258.GL8923@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Max Filippov <jcmvbkbc@gmail.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Tony Luck <tony.luck@intel.com>



On Tue, 4 Jun 2013, Peter Zijlstra wrote:
> 
> And here's the patch that makes fast mode go *poof*..

Let's just do this. Mind sending a patch with proper changelog and 
sign-off?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
