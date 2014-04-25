Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 04B8E6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 12:30:58 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id rd3so1502199pab.16
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 09:30:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wg2si5195667pab.44.2014.04.25.09.30.56
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 09:30:56 -0700 (PDT)
Message-ID: <535A8DBC.4010202@intel.com>
Date: Fri, 25 Apr 2014 09:30:52 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Dirty/Access bits vs. page content
References: <53558507.9050703@zytor.com>	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>	<53559F48.8040808@intel.com>	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>	<20140422075459.GD11182@twins.programming.kicks-ass.net>	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>	<alpine.LSU.2.11.1404221847120.1759@eggly.anvils>	<20140423184145.GH17824@quack.suse.cz>	<CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>	<20140424065133.GX26782@laptop.programming.kicks-ass.net>	<alpine.LSU.2.11.1404241110160.2443@eggly.anvils>	<CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>	<alpine.LSU.2.11.1404241252520.3455@eggly.anvils> <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
In-Reply-To: <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On 04/24/2014 04:46 PM, Linus Torvalds wrote:
> IOW, how about the attached patch that entirely replaces my previous
> two patches. DaveH - does this fix your test-case, while _not_
> introducing any new BUG_ON() triggers?
> 
> I didn't test the patch, maybe I did something stupid. It compiles for
> me, but it only works for the HAVE_GENERIC_MMU_GATHER case, but
> introducing tlb_flush_mmu_tlbonly() and tlb_flush_mmu_free() into the
> non-generic cases should be trivial, since they really are just that
> old "tlb_flush_mmu()" function split up (the tlb_flush_mmu() function
> remains available for other non-forced flush users)
> 
> So assuming this does work for DaveH, then the arm/ia64/um/whatever
> people would need to do those trivial transforms too, but it really
> shouldn't be too painful.

It looks happy on both my debugging kernel (which was triggering it
before) and the one without lockdep and all the things that normally
slow it down and change timing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
