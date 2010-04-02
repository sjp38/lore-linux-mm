Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D56746B01E3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 16:57:46 -0400 (EDT)
Date: Fri, 2 Apr 2010 22:55:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100402205535.GA4842@redhat.com>
References: <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <alpine.DEB.2.00.1004021159310.1773@chino.kir.corp.google.com> <20100402191414.GA982@redhat.com> <alpine.DEB.2.00.1004021244010.15445@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004021244010.15445@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/02, David Rientjes wrote:
>
> On Fri, 2 Apr 2010, Oleg Nesterov wrote:
> >
> > > I prefer to keep oom_badness() to be a positive range as
> > > it always has been (and /proc/pid/oom_score has always used an unsigned
> > > qualifier),
> >
> > Yes, I thought about /proc/pid/oom_score, but imho this is minor issue.
> > We can s/%lu/%ld/ though, or just report 0 if oom_badness() returns -1.
> > Or something.
>
> Just have it return 0, meaning never kill, and then ensure "chosen" is
> never set for an oom_badness() of 0, even if we don't have another task to
> kill.  That's how Documentation/filesystems/proc.txt describes it anyway.

OK, agreed, this makes more sense and more clean. I misunderstood you even
more before.

Thanks, I'll redo/resend 3/4.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
