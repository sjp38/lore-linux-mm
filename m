Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 442AE6B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 01:13:31 -0400 (EDT)
Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
From: Jon Masters <jonathan@jonmasters.org>
In-Reply-To: <20090605134641.FC25.A69D9226@jp.fujitsu.com>
References: <1228331069.6693.73.camel@lts-notebook>
	 <1244176757.11597.24.camel@localhost.localdomain>
	 <20090605134641.FC25.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 05 Jun 2009 01:12:49 -0400
Message-Id: <1244178769.11597.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-05 at 13:49 +0900, KOSAKI Motohiro wrote:
> > On Wed, 2008-12-03 at 14:04 -0500, Lee Schermerhorn wrote:
> > 
> > > Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):
> > 
> > FWIW, I really liked this patch series. And I think there is still value
> > in a generic "mlock" wrapper utility that I can use. Sure, the later on
> > containers suggestions are all wonderful in theory but I don't see that
> > that went anywhere either (and I disagree that we can't trust people to
> > use this right without doing silly things) - if I'm really right that
> > this got dropped on the floor, can we resurrect it in .31 please?
> 
> I guess Lee is really really busy now.

Who isn't? :)

> Can you make V3 patch instead?

I'm happy to rebase onto a recent kernel and repost if it's not
something that's instantly going to get dropped on the floor. I thought
about this patch series a few minutes ago when I found myself
recompiling a certain piece of audio software and realized there's no
reason I shouldn't just be able to e.g. just do the following:

mlock --all -- pulseaudio --start --high-priority=1

As a test of my sanity in this case, but there are other times when I'm
running software on RT kernels and would love to have that as a wrapper
to temporarily prevent a performance hit.

Jon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
