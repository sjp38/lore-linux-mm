Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1C3AE6B00B0
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 19:29:08 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1I0T6LX024009
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Feb 2009 09:29:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 20DCE45DE53
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:29:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 001EF45DE52
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:29:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DC78D1DB805E
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:29:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 899A01DB803C
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:29:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
In-Reply-To: <20090217143321.GB5888@nowhere>
References: <20090217201651.576E.A69D9226@jp.fujitsu.com> <20090217143321.GB5888@nowhere>
Message-Id: <20090218091726.898D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 18 Feb 2009 09:29:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi Frederic,

> > And, both function is freqentlly called one.
> > I worry about performance issue. can you prove no degression?
> 
> It would be very hard to prove. Tracepoints are very cheap in that they only
> add the overhead of a single branch check while off.

this is typical reviewing comment.

Memory folks adage says,
	Don't believe theory, you believe benchmark result.

I don't oppose your theorical background opinion :)


> But are there some plans about writing a tracer or so for pagecache?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
