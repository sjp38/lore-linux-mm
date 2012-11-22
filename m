Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id BEA886B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 20:21:29 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so5401757eek.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 17:21:28 -0800 (PST)
Date: Thu, 22 Nov 2012 02:21:22 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: numa/core regressions fixed - more testers wanted
Message-ID: <20121122012122.GA7938@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <20121120152933.GA17996@gmail.com>
 <20121120175647.GA23532@gmail.com>
 <CAGjg+kHKaQLcrnEftB+2mjeCjGUBiisSOpNCe+_9-4LDho9LpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGjg+kHKaQLcrnEftB+2mjeCjGUBiisSOpNCe+_9-4LDho9LpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <lkml.alex@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Alex Shi <lkml.alex@gmail.com> wrote:

> >
> > Those of you who would like to test all the latest patches are
> > welcome to pick up latest bits at tip:master:
> >
> >    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
> >
> 
> I am wondering if it is a problem, but it still exists on HEAD: c418de93e39891
> http://article.gmane.org/gmane.linux.kernel.mm/90131/match=compiled+with+name+pl+and+start+it+on+my
> 
> like when just start 4 pl tasks, often 3 were running on node 
> 0, and 1 was running on node 1. The old balance will average 
> assign tasks to different node, different core.

This is "normal" in the sense that the current mainline 
scheduler is (supposed to be) doing something similar: if the 
node is still within capacity, then there's no reason to move 
those threads.

OTOH, I think with NUMA balancing we indeed want to spread them 
better, if those tasks do not share memory with each other but 
use their own memory. If they share memory then they should 
remain on the same node if possible.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
