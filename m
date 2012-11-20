Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 335526B0070
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 20:02:35 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hm11so399689wib.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 17:02:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121119223604.GA13470@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Nov 2012 15:02:13 -1000
Message-ID: <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 12:36 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> Hugepages is a must for most forms of NUMA/HPC. This alone
> questions the relevance of most of your prior numa/core testing
> results. I now have to strongly dispute your other conclusions
> as well.

Ingo, stop doing this kind of crap.

Let's make it clear: if the NUMA patches continue to regress
performance for reasonable loads (and that very much includes "no
THP") then they won't be merged.

You seem to be in total denial. Every time Mel sends out results that
show that your patches MAKE PERFORMANCE WORSE you blame Mel, or blame
the load, and never seem to admit that performance got worse.

Stop it. That kind of "head-in-the-sand" behavior is not conducive to
good code, and I have absolutely *zero* interest in merging a branch
that has been tested with only your load on only your machine, and
performs better on that *one* load, and then regresses on other loads.

Seriously. If you can't make the non-THP case go faster, don't even
bother sending out the patches.

Similarly, if you cannot take performance results from others, don't
even bother sending out the patches. If all you care about is your own
special case, then keep the patches on your own machine, and stop
bothering others with your patches.

So stop ignoring the feedback, and stop shooting the messenger. Look
at the numbers, and admit that there is something that needs to be
fixed.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
