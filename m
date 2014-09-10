Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 89A356B00B3
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 17:35:50 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id i7so13615305oag.6
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:35:50 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id m2si4572671oes.100.2014.09.10.14.35.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 14:35:49 -0700 (PDT)
Message-ID: <1410384315.28990.308.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle
 WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 15:25:15 -0600
In-Reply-To: <CALCETrV4DEr7tQUPCSzJMjBwgJ3-Xgcw8PFt_CCDbMoWRQ4Uug@mail.gmail.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	 <1410367910-6026-3-git-send-email-toshi.kani@hp.com>
	 <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
	 <1410377428.28990.260.camel@misato.fc.hp.com> <5410B10A.4030207@zytor.com>
	 <1410381050.28990.295.camel@misato.fc.hp.com>
	 <CALCETrUz016rDogLFTVETLh7ybVjgOMOhkL5kF2wJTLUF041xQ@mail.gmail.com>
	 <1410383484.28990.303.camel@misato.fc.hp.com>
	 <CALCETrV4DEr7tQUPCSzJMjBwgJ3-Xgcw8PFt_CCDbMoWRQ4Uug@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 14:27 -0700, Andy Lutomirski wrote:
> On Wed, Sep 10, 2014 at 2:11 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Wed, 2014-09-10 at 14:06 -0700, Andy Lutomirski wrote:
> >> On Wed, Sep 10, 2014 at 1:30 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> >> > On Wed, 2014-09-10 at 13:14 -0700, H. Peter Anvin wrote:
> >> >> On 09/10/2014 12:30 PM, Toshi Kani wrote:
> >> >> >
> >> >> > When WT is unavailable due to the PAT errata, it does not fail but gets
> >> >> > redirected to UC-.  Similarly, when PAT is disabled, WT gets redirected
> >> >> > to UC- as well.
> >> >> >
> >> >>
> >> >> But on pre-PAT hardware you can still do WT.
> >> >
> >> > Yes, if we manipulates the bits directly, but such code is no longer
> >> > allowed for PAT systems.  The PAT-based kernel interfaces won't work for
> >> > pre-PAT systems, and therefore requests are redirected to UC- on such
> >> > systems.
> >> >
> >>
> >> Right, the PWT bit.  Forgot about that.
> >>
> >> I wonder whether it would make sense to do some followup patches to
> >> replace the current support for non-PAT machines with a "PAT" and
> >> corresponding reverse map that exactly matches the mapping when PAT is
> >> disabled.  These patches are almost there.
> >
> > That's possible, but the only benefit is that we can enable WT on
> > pre-PAT systems, which I do not think anyone cares now...  WB & UC work
> > on pre-PAT systems.  WC & WT need PAT.  I think this requirement is
> > reasonable.
> 
> It might end up being a cleanup, though.  A whole bunch of
> rarely-exercised if (!pat_enabled) things would go away.

Good point.  I will work on it. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
