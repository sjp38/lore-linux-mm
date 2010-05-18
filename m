Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 42BDB6B01D1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 12:10:45 -0400 (EDT)
Subject: Re: Unexpected splice "always copy" behavior observed
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <1274197993.26328.755.camel@gandalf.stny.rr.com>
References: <20100518153440.GB7748@Krystal>
	 <1274197993.26328.755.camel@gandalf.stny.rr.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 18 May 2010 12:10:39 -0400
Message-ID: <1274199039.26328.758.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-18 at 11:53 -0400, Steven Rostedt wrote:

> I'm currently looking at the network code to see if it is better.

The network code seems to do the right thing. It sends the actual page
directly to the network.

Hopefully we can find a way to avoid the copy to file. But the splice
code was created to avoid the copy to and from userspace, it did not
guarantee no copy within the kernel itself.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
