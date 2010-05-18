Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4916B0218
	for <linux-mm@kvack.org>; Tue, 18 May 2010 11:24:18 -0400 (EDT)
Subject: Re: [RFC] Tracer Ring Buffer splice() vs page cache [was: Re: Perf
 and ftrace [was Re: PyTimechart]]
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100518151626.GA7748@Krystal>
References: <20100514183242.GA11795@Krystal>
	 <1273862945.1674.14.camel@laptop> <20100517224243.GA10603@Krystal>
	 <1274185160.5605.7787.camel@twins>  <20100518151626.GA7748@Krystal>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 18 May 2010 17:23:53 +0200
Message-ID: <1274196233.5605.8169.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-18 at 11:16 -0400, Mathieu Desnoyers wrote:
> > Also, suppose it was still in the page-cache and still dirty, a steal()
> > would then punch a hole in the file.
>=20
> page_cache_pipe_buf_steal starts by doing a wait_on_page_writeback(page);=
 and
> then does a try_to_release_page(page, GFP_KERNEL). Only if that succeeds =
is the
> action of stealing succeeding.=20

If you're going to wait for writeback I don't really see the advantage
of stealing over simply allocating a new page.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
