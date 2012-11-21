Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 53CAC6B0044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:02:51 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id dq11so2496690wgb.26
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:02:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121120090637.GA14873@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com>
 <20121120060014.GA14065@gmail.com> <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com> <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
 <20121120090637.GA14873@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Nov 2012 07:02:29 -1000
Message-ID: <CA+55aFyR9FsGYWSKkgsnZB7JhheDMjEQgbzb0gsqawSTpetPvA@mail.gmail.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 11:06 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> Oh, finally a clue: you seem to have vsyscall emulation
> overhead!

Ingo, stop it already!

This is *exactly* the kind of "blame everybody else than yourself"
behavior that I was talking about earlier.

There have been an absolute *shitload* of patches to try to make up
for the schednuma regressions THAT HAVE ABSOLUTELY NOTHING TO DO WITH
SCHEDNUMA, and are all about trying to work around the fact that it
regresses. The whole TLB optimization, and now this kind of crap.

Ingo, look your code in the mirror some day, and ask yourself: why do
you think this fixes a "regression"?

The fact is, the *baseline* had the exact same vsyscall emulation too.
So by trying to make up for vsyscalls only in your numbers, you are
basically trying to lie about regressions, and try to cover up the
schednuma regression by fixing something else.

See? That's bogus. When you now compare numbers, YOU ARE LYING. You
have introduced a performance regression, and then trying to hide it
by making something else go faster.

The same is true of all your arguments about Mel's numbers wrt THP
etc. Your arguments are misleading - either intentionally, of because
you yourself didn't think things through. For schednuma, it's not
enough to be par with mainline with THP off - the competition
(autonuma) has been beating mainline soundly in Mel's configuration.
So the target to beat is not mainline, but the much *higher*
performance that autonuma got.

The fact that Mel has a different configuration from yours IS
IRRELEVANT. You should not blame his configuration for the regression,
you should instead ask yourself "Why does schednuma regress in that
configuration"? And not look at vsyscalls or anything, but look at
what schednuma does wrong!

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
