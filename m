Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2743B6B004D
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 16:54:07 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so6504330ied.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 13:54:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50A7AC33.5060308@redhat.com>
References: <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com>
 <20121026132601.GC9886@gmail.com> <20121026144502.6e94643e@dull>
 <20121026221254.7d32c8bf@pyramind.ukuu.org.uk> <508BE459.2080406@redhat.com>
 <20121029165705.GA4693@x1.osrc.amd.com> <CA+55aFzbwaHxWPkJ-t-TEh9hUwmA+D-unHGuJ7FPx7ULmrwKMg@mail.gmail.com>
 <20121117145015.GF16441@x1.osrc.amd.com> <CA+55aFxunZ94QkhxUKB0iJ0p1mFuWGzr0mR8icM=XJZadcSuRw@mail.gmail.com>
 <50A7AC33.5060308@redhat.com>
From: Shentino <shentino@gmail.com>
Date: Sat, 17 Nov 2012 13:53:26 -0800
Message-ID: <CAGDaZ_qF03zB2XTF2nXtsPh1Zf90zVn-ZaoZSNAQg7BGyYEaww@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86,mm: drop TLB flush from ptep_set_access_flags
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Florian Fainelli <florian@openwrt.org>, Borislav Petkov <borislav.petkov@amd.com>

On Sat, Nov 17, 2012 at 7:24 AM, Rik van Riel <riel@redhat.com> wrote:
> On 11/17/2012 09:56 AM, Linus Torvalds wrote:
>>
>> On Sat, Nov 17, 2012 at 6:50 AM, Borislav Petkov <bp@alien8.de> wrote:
>>>
>>> I don't know, however, whether it would be prudent to have some sort of
>>> a cheap assertion in the code (cheaper than INVLPG %ADDR, although on
>>> older cpus we do MOV CR3) just in case. This should be enabled only with
>>> DEBUG_VM on, of course...
>>
>>
>> I wonder how we could actually test for it. We'd have to have some
>> per-cpu page-fault address check (along with a generation count on the
>> mm or similar). I doubt we'd figure out anything that works reliably
>> and efficiently and would actually show any problems
>
> Would it be enough to simply print out a warning if we fault
> on the same address twice (or three times) in a row, and then
> flush the local TLB?
>
> I realize this would not just trigger on CPUs that fail to
> invalidate TLB entries that cause faults, but also on kernel
> paths that cause a page fault to be re-taken...

I'm actually curious if the architecture docs/software developer
manuals for IA-32 mandate any TLB invalidations on a #PF

Is there any official vendor documentation on the subject?

And perhaps equally valid, should we trust it if it exists?

> ... but then again, don't we want to find those paths and
> fix them, anyway? :)
>
> --
> All rights reversed
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
