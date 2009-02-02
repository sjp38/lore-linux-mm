Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B789B5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 10:48:24 -0500 (EST)
Subject: Re: [RFC v7] wait: prevent exclusive waiter starvation
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <1233239675.10354.18.camel@think.oraclecorp.com>
References: <20090123095904.GA22890@cmpxchg.org>
	 <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com>
	 <20090126215957.GA3889@cmpxchg.org> <20090127032359.GA17359@redhat.com>
	 <20090127193434.GA19673@cmpxchg.org> <20090127200544.GA28843@redhat.com>
	 <20090128091453.GA22036@cmpxchg.org> <20090129044227.GA5231@redhat.com>
	 <20090128233734.81d8004a.akpm@linux-foundation.org>
	 <20090129083108.GA27495@redhat.com>
	 <20090129011143.884e5573.akpm@linux-foundation.org>
	 <1233239675.10354.18.camel@think.oraclecorp.com>
Content-Type: text/plain
Date: Mon, 02 Feb 2009 10:47:47 -0500
Message-Id: <1233589667.18113.24.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-01-29 at 09:34 -0500, Chris Mason wrote:

> > > > So I think we're saying that
> > > > lock_page_killable-avoid-lost-wakeups.patch actually did fix the bug?
> > > 
> > > I think yes,
> > > 
> 
> Our test case that was able to reliably trigger the bug was fixed by
> lock_page_killable-avoid-lost-wakeups.patch.
> 
> I'll ask them to test v7 as well.  The run takes about a day, so
> confirmation will take a bit.

v7 went through a total of 5 runs and passed all of them.  Unpatched we
would fail after one run, so I think this does fix it.

-chris




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
