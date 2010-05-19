Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CAC126008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 11:33:46 -0400 (EDT)
In-reply-to: <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org>
	(message from Linus Torvalds on Wed, 19 May 2010 07:59:48 -0700 (PDT))
Subject: Re: Unexpected splice "always copy" behavior observed
References: <20100518153440.GB7748@Krystal>  <1274197993.26328.755.camel@gandalf.stny.rr.com>  <1274199039.26328.758.camel@gandalf.stny.rr.com>  <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>  <20100519063116.GR2516@laptop>
 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org>
Message-Id: <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 19 May 2010 17:33:11 +0200
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: rostedt@goodmis.org, npiggin@suse.de, mathieu.desnoyers@efficios.com, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 May 2010, Linus Torvalds wrote:
> Btw, since you apparently have a real case - is the "splice to file" 
> always just an append? IOW, if I'm not right in assuming that the only 
> sane thing people would reasonable care about is "append to a file", then 
> holler now.

Virtual machines might reasonably need this for splicing to a disk
image.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
