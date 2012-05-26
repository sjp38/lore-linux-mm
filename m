Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B74C16B0092
	for <linux-mm@kvack.org>; Sat, 26 May 2012 16:43:18 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so555745wgb.2
        for <linux-mm@kvack.org>; Sat, 26 May 2012 13:43:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FC112AB.1040605@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <4FC112AB.1040605@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 May 2012 13:42:56 -0700
Message-ID: <CA+55aFxpD+LsE+aNvDJtz9sGsGMvdusisgOY3Csbzyx1mEqW-w@mail.gmail.com>
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Sat, May 26, 2012 at 10:28 AM, Rik van Riel <riel@redhat.com> wrote:
>
> It would be good to get everybody's ideas out there on this
> topic, because this is the fundamental factor in deciding
> between Peter's approach to NUMA and Andrea's approach.
>
> Ingo? Andrew? Linus? Paul?

I'm a *firm* believer that if it cannot be done automatically "well
enough", the absolute last thing we should ever do is worry about the
crazy people who think they can tweak it to perfection with complex
interfaces.

You can't do it, except for trivial loads (often benchmarks), and for
very specific machines.

So I think very strongly that we should entirely dismiss all the
people who want to do manual placement and claim that they know what
their loads do. They're either full of sh*t (most likely), or they
have a very specific benchmark and platform that they are tuning for
that is totally irrelevant to everybody else.

What we *should* try to aim for is a system that doesn't do horribly
badly right out of the box. IOW, no tuning what-so-ever (at most a
kind of "yes, I want you to try to do the NUMA thing" flag to just
enable it at all), and try to not suck.

Seriously. "Try to avoid sucking" is *way* superior to "We can let the
user tweak things to their hearts content". Because users won't get it
right.

Give the anal people a knob they can tweak, and tell them it does
something fancy. And never actually wire the damn thing up. They'll be
really happy with their OCD tweaking, and do lots of nice graphs that
just show how the error bars are so big that you can find any damn
pattern you want in random noise.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
