Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 612F66B0259
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 13:17:24 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 63so19086121pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 10:17:24 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b8si51339416pfd.34.2016.03.03.10.17.23
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 10:17:23 -0800 (PST)
Date: Thu, 3 Mar 2016 18:17:14 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv2 0/3] KASAN: clean stale poison upon cold re-entry to
 kernel
Message-ID: <20160303181714.GH19139@leverpostej>
References: <1457024068-2236-1-git-send-email-mark.rutland@arm.com>
 <CAG_fn=WAfu4oD1Qb1xUnX765RpUznWm1y+FKYqqiM8VO53F+Ag@mail.gmail.com>
 <20160303174015.GG19139@leverpostej>
 <CAG_fn=VBOqPSwhKy2OCj7cgM=XaD338L=UfPDcg9X3tCwc6B_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VBOqPSwhKy2OCj7cgM=XaD338L=UfPDcg9X3tCwc6B_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, mingo@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, catalin.marinas@arm.com, lorenzo.pieralisi@arm.com, peterz@infradead.org, will.deacon@arm.com, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Thu, Mar 03, 2016 at 06:45:55PM +0100, Alexander Potapenko wrote:
> On Thu, Mar 3, 2016 at 6:40 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > Hi,
> >
> > On Thu, Mar 03, 2016 at 06:17:31PM +0100, Alexander Potapenko wrote:
> >> Please replace "ASAN" with "KASAN".
> >>
> >> On Thu, Mar 3, 2016 at 5:54 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> >> > Functions which the compiler has instrumented for ASAN place poison on
> >> > the stack shadow upon entry and remove this poison prior to returning.

[...]

> > For the above, and the rest of the series, ASAN consistently refers to
> > the compiler AddressSanitizer feature, and KASAN consistently refers to
> > the Linux-specific infrastructure. A simple s/[^K]ASAN/KASAN/ would
> > arguably be wrong (e.g. when referring to GCC behaviour above).
> I don't think there's been any convention about the compiler feature
> name, we usually talked about ASan as a userspace tool and KASAN as a
> kernel-space one, although they share the compiler part.

Ah, ok.

In future I'll speak in terms of "AddressSanitizer instrumentation" or
something like that, as that's fairly unambigious.

> > If there is a this needs rework, then I'm happy to s/[^K]ASAN/ASan/ to
> > follow the usual ASan naming convention and avoid confusion. Otherwise,
> > spinning a v3 is simply churn.
> I don't insist on changing this, I should've chimed in before.
> Feel free to retain the above patch description.

No worries, thanks for the info.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
