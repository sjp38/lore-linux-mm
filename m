Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7964E6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 10:14:46 -0500 (EST)
Date: Tue, 24 Nov 2009 09:14:03 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
In-Reply-To: <20091124071250.GC2999@redhat.com>
Message-ID: <alpine.DEB.2.00.0911240906360.14045@router.home>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com> <1258985167-29178-11-git-send-email-gleb@redhat.com> <1258990455.4531.594.camel@laptop> <20091123155851.GU2999@redhat.com> <alpine.DEB.2.00.0911231128190.785@router.home>
 <20091124071250.GC2999@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009, Gleb Natapov wrote:

> On Mon, Nov 23, 2009 at 11:30:02AM -0600, Christoph Lameter wrote:
> > This adds significant overhead for the !PREEMPT case adding lots of code
> > in critical paths all over the place.
> I want to measure it. Can you suggest benchmarks to try?

AIM9 (reaim9)?

Any test suite will do that tests OS performance.

Latency will also be negatively impacted. There are already significant
regressions in recent kernel releases so many of us who are sensitive
to these issues just stick with old kernels (2.6.22 f.e.) and hope
that the upstream issues are worked out at some point.

There is also lldiag package in my directory. See

http://www.kernel.org/pub/linux/kernel/people/christoph/lldiag

Try the latency test and the mcast test. Localhost multicast is typically
a good test for kernel performance.

There is also the page fault test that Kamezawa-san posted recently in the
thread where we tried to deal with the long term mmap_sem issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
