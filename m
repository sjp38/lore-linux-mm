Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A86C26B0088
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:24:48 -0500 (EST)
Date: Tue, 17 Feb 2009 10:24:46 -0500 (EST)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
In-Reply-To: <499A99BC.2080700@bk.jp.nec.com>
Message-ID: <alpine.DEB.1.10.0902171021320.910@gandalf.stny.rr.com>
References: <499A7CAD.9030409@bk.jp.nec.com> <1234863220.4744.34.camel@laptop> <499A99BC.2080700@bk.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>


On Tue, 17 Feb 2009, Atsushi Tsuji wrote:
> > 
> > This is rather asymmetric, why don't we care about the offset for the
> > removed page?
> > 
> 
> Indeed.
> I added the offset to the argument for the removed page and resend fixed patch.
> 
> Signed-off-by: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>

Could you package it up in one patch again and resend with [PATCH v2].
Also make sure to Cc the memory folks, and ask for an Acked-by from them.

Thanks,

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
