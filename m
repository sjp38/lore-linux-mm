Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 40FB66B021A
	for <linux-mm@kvack.org>; Tue, 18 May 2010 08:19:49 -0400 (EDT)
Subject: Re: [RFC] Tracer Ring Buffer splice() vs page cache [was: Re: Perf
 and ftrace [was Re: PyTimechart]]
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100517224243.GA10603@Krystal>
References: <20100514183242.GA11795@Krystal>
	 <1273862945.1674.14.camel@laptop>  <20100517224243.GA10603@Krystal>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 18 May 2010 14:19:20 +0200
Message-ID: <1274185160.5605.7787.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-17 at 18:42 -0400, Mathieu Desnoyers wrote:
> I'll continue to look into this. One of the things I noticed that that we=
 could
> possibly use the "steal()" operation to steal the pages back from the pag=
e cache
> to repopulate the ring buffer rather than continuously allocating new pag=
es. If
> steal() fails for some reasons, then we can fall back on page allocation.=
 I'm
> not sure it is safe to assume anything about pages being in the page cach=
e
> though.=20

Also, suppose it was still in the page-cache and still dirty, a steal()
would then punch a hole in the file.

> Maybe the safest route is to just allocate new pages for now.

Yes, that seems to be the only sane approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
