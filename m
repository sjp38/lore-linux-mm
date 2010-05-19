Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 31557600385
	for <linux-mm@kvack.org>; Wed, 19 May 2010 11:12:38 -0400 (EDT)
Subject: Re: Unexpected splice "always copy" behavior observed
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org>
References: <20100518153440.GB7748@Krystal>
	 <1274197993.26328.755.camel@gandalf.stny.rr.com>
	 <1274199039.26328.758.camel@gandalf.stny.rr.com>
	 <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
	 <20100519063116.GR2516@laptop>
	 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org>
	 <1274280968.26328.774.camel@gandalf.stny.rr.com>
	 <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Wed, 19 May 2010 11:12:36 -0400
Message-ID: <1274281956.26328.776.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-19 at 07:59 -0700, Linus Torvalds wrote:
> 

> Btw, since you apparently have a real case - is the "splice to file" 
> always just an append? IOW, if I'm not right in assuming that the only 
> sane thing people would reasonable care about is "append to a file", then 
> holler now.

My use case is just to move the data from the ring buffer into a file
(or network) as fast as possible. It creates a new file and all
additions are "append to a file".

I believe Mathieu does the same.

With me, you are correct.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
