Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C29B26B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 16:59:18 -0400 (EDT)
Message-ID: <641426.722.qm@web114309.mail.gq1.yahoo.com>
Date: Wed, 19 May 2010 13:59:16 -0700 (PDT)
From: Rick Sherm <rick.sherm@yahoo.com>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, arjan@infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry for deleting CC'd addresses. yahoo was whining...

--- On Wed, 5/19/10, Linus Torvalds <torvalds@linux-foundation.org> wrote:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Subject: Re: Unexpected splice "always copy" behavior observed
> To: "Steven Rostedt" <rostedt@goodmis.org>
> Cc: "Nick Piggin" <npiggin@suse.de>, "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>, "Peter Zijlstra" <peterz@infradead.org>, "Frederic Weisbecker" <fweisbec@gmail.com>, "Pierre Tardy" <tardyp@gmail.com>, "Ingo Molnar" <mingo@elte.hu>, "Arnaldo Carvalho de Melo" <acme@redhat.com>, "Tom Zanussi" <tzanussi@gmail.com>, "Paul Mackerras" <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, "davem" <davem@davemloft.net>, linux-mm@kvack.org, "Andrew Morton" <akpm@linux-foundation.org>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, "Christoph Lameter" <cl@linux-foundation.org>, "Tejun Heo" <tj@kernel.org>, "Jens Axboe" <jens.axboe@oracle.com>
> Date: Wednesday, May 19, 2010, 2:59 PM
> 
> 
> On Wed, 19 May 2010, Steven Rostedt wrote:
> 
> > On Wed, 2010-05-19 at 07:39 -0700, Linus Torvalds
> wrote:
> > 
> > > The real limitation is likely always going to be
> the fact that it has to 
> > > be page-aligned and a full page. For a lot of
> splice inputs, that simply 
> > > won't be the case, and you'll end up copying for
> alignment reasons anyway.
> > 
> > That's understandable. For the use cases of splice I
> use, I work to make
> > it page aligned and full pages. Anyone else using
> splice for
> > optimizations, should do the same. It only makes
> sense.
> > 
> > The end of buffer may not be a full page, but then
> it's the end anyway,
> > and I'm not as interested in the speed.
> 
> Btw, since you apparently have a real case - is the "splice
> to file" 
> always just an append? IOW, if I'm not right in assuming
> that the only 
> sane thing people would reasonable care about is "append to
> a file", then 
> holler now.
> 

I've a similar 'append' use case:
http://marc.info/?l=linux-kernel&m=127143736527459&w=4

My mmapped buffers are pinned down.


      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
