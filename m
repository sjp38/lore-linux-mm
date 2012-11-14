Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9CEE66B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 23:28:51 -0500 (EST)
Date: Tue, 13 Nov 2012 20:28:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 21/31] sched, numa, mm: Implement THP migration
Message-Id: <20121113202846.5b1c0e3c.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1211131759390.29612@eggly.anvils>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
	<1352826834-11774-22-git-send-email-mingo@kernel.org>
	<20121113184835.GH10092@cmpxchg.org>
	<alpine.LNX.2.00.1211131759390.29612@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Zhouping Liu <zliu@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, 13 Nov 2012 18:23:13 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> But I vehemently hope that this all very soon vanishes from linux-next,
> and the new stuff is worked on properly for a while, in a separate
> development branch of tip, hopefully converging with Mel's.

Yes please.

The old code in -next has been causing MM integration problems for
months, and -next shuts down from Nov 15 to Nov 26, reopening around
3.7-rc7.  rc7 is too late for this material - let's shoot for
integration in -next at 3.8-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
