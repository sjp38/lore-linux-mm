Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D53186B01D0
	for <linux-mm@kvack.org>; Tue, 18 May 2010 11:57:05 -0400 (EDT)
Date: Tue, 18 May 2010 10:56:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <20100518155135.GJ2516@laptop>
Message-ID: <alpine.DEB.2.00.1005181055260.16649@router.home>
References: <20100518153440.GB7748@Krystal> <20100518155135.GJ2516@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 19 May 2010, Nick Piggin wrote:

> What would be needed is to have filesystem maintainers go through and
> enable it on a case by case basis. It's trivial for tmpfs/ramfs type
> filesystems and I have a patch for those, but I never posted it on.yet.
> Even basic buffer head filesystems IIRC get a little more complex --
> but we may get some milage just out of invalidating the existing
> pagecache rather than getting fancy and trying to move buffers over
> to the new page.

There is a "migration" address space operation for moving pages. Page
migration requires that in order to be able to move dirty pages. Can
splice use that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
