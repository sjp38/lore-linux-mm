Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5F2FE6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:22:50 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 950E582C5A1
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:22:48 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kkr82ZytG3l6 for <linux-mm@kvack.org>;
	Tue, 10 Nov 2009 15:22:48 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DB20482C522
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:22:43 -0500 (EST)
Date: Tue, 10 Nov 2009 15:20:41 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
  instead
In-Reply-To: <28c262360911062019q254f7541lbdc3d94491a69bd6@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0911101519250.14300@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>  <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>  <28c262360911060741x3f7ab0a2k15be645e287e05ac@mail.gmail.com>  <alpine.DEB.1.10.0911061209520.5187@V090114053VZO-1>
 <28c262360911062019q254f7541lbdc3d94491a69bd6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Sat, 7 Nov 2009, Minchan Kim wrote:

> On Sat, Nov 7, 2009 at 2:10 AM, Christoph Lameter
> <cl@linux-foundation.org> wrote:
> > On Sat, 7 Nov 2009, Minchan Kim wrote:
> >
> >> How about change from 'mm_readers' to 'is_readers' to improve your
> >> goal 'scalibility'?
> >
> > Good idea. Thanks. Next rev will use your suggestion.
> >
> > Any creative thoughts on what to do about the 1 millisecond wait period?
> >
>
> Hmm,
> it would be importatn to prevent livelock for reader to hold lock
> continuously before
> hodling writer than 1 msec write ovhead.

Livelock because there are too frequent readers?

We could just keep the mutex locked to ensure that no new readers arrive.

> First of all, After we solve it, second step is that optimize write
> overhead, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
