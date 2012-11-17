Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id CE6356B004D
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 09:49:57 -0500 (EST)
Date: Sat, 17 Nov 2012 15:50:15 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 2/3] x86,mm: drop TLB flush from ptep_set_access_flags
Message-ID: <20121117145015.GF16441@x1.osrc.amd.com>
References: <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org>
 <508A8D31.9000106@redhat.com>
 <20121026132601.GC9886@gmail.com>
 <20121026144502.6e94643e@dull>
 <20121026221254.7d32c8bf@pyramind.ukuu.org.uk>
 <508BE459.2080406@redhat.com>
 <20121029165705.GA4693@x1.osrc.amd.com>
 <CA+55aFzbwaHxWPkJ-t-TEh9hUwmA+D-unHGuJ7FPx7ULmrwKMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+55aFzbwaHxWPkJ-t-TEh9hUwmA+D-unHGuJ7FPx7ULmrwKMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, florian@openwrt.org, Borislav Petkov <borislav.petkov@amd.com>

On Mon, Oct 29, 2012 at 10:06:15AM -0700, Linus Torvalds wrote:
> On Mon, Oct 29, 2012 at 9:57 AM, Borislav Petkov <bp@alien8.de> wrote:
> >
> > On current AMD64 processors,
> 
> Can you verify that this is true for older cpu's too (ie the old
> pre-64-bit ones, say K6 and original Athlon)?

Albeit with a slight delay, the answer is yes: all AMD cpus
automatically invalidate cached TLB entries (and intermediate walk
results, for that matter) on a #PF.

I don't know, however, whether it would be prudent to have some sort of
a cheap assertion in the code (cheaper than INVLPG %ADDR, although on
older cpus we do MOV CR3) just in case. This should be enabled only with
DEBUG_VM on, of course...

HTH.

-- 
Regards/Gruss,
Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
