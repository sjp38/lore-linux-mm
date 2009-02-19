Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBBA6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 13:52:13 -0500 (EST)
Date: Thu, 19 Feb 2009 13:51:54 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
Message-ID: <20090219185154.GA24117@infradead.org>
References: <499A7CAD.9030409@bk.jp.nec.com> <1234863220.4744.34.camel@laptop> <499A99BC.2080700@bk.jp.nec.com> <alpine.DEB.1.10.0902171021320.910@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902171021320.910@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 17, 2009 at 10:24:46AM -0500, Steven Rostedt wrote:
> 
> On Tue, 17 Feb 2009, Atsushi Tsuji wrote:
> > > 
> > > This is rather asymmetric, why don't we care about the offset for the
> > > removed page?
> > > 
> > 
> > Indeed.
> > I added the offset to the argument for the removed page and resend fixed patch.
> > 
> > Signed-off-by: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
> 
> Could you package it up in one patch again and resend with [PATCH v2].
> Also make sure to Cc the memory folks, and ask for an Acked-by from them.

Well, until we actually get a consumer of those tracepoints, e.g. a
ftrace pluging into the tree strong NACK for me.

(p.s. I really don't get it why people keep trying to push dead code
 into the tree)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
