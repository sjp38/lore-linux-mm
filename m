Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 9A82D6B004D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 12:30:32 -0500 (EST)
Date: Tue, 4 Dec 2012 18:30:17 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 00/10] Latest numa/core release, v18
In-Reply-To: <20121203134110.GL8218@suse.de>
Message-ID: <alpine.LFD.2.02.1212041825140.2701@ionos>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org> <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com> <20121203134110.GL8218@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, 3 Dec 2012, Mel Gorman wrote:
> On Fri, Nov 30, 2012 at 12:37:49PM -0800, Linus Torvalds wrote:
> > So if this is a migration-specific scalability issue, then it might be
> > possible to solve by making the mutex be a rwsem instead, and have
> > migration only take it for reading.
> > 
> > Of course, I'm quite possibly wrong, and the code depends on full
> > mutual exclusion.
> > 
> > Just a thought, in case it makes somebody go "Hmm.."
> > 
> 
> Offhand, I cannot think of a reason why a rwsem would not work. This
> thing originally became a mutex because the RT people (Peter in
> particular) cared about being able to preempt faster. It'd be nice if
> they confirmed that rwsem is not be a problem for them.

rwsems are preemptable as well. So I don't think this was Peter's main
concern. If it works with an rwsem, then go ahead.

rwsems degrade on RT because we cannot do multiple reader boosting, so
they allow only a single reader which can take it recursive. But
that's an RT specific issue and nothing you should worry about.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
