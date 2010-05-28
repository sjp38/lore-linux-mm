Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 858586B01C1
	for <linux-mm@kvack.org>; Thu, 27 May 2010 22:39:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S2duU1009657
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 11:39:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30FB345DE70
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:39:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C25B45DE60
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:39:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DEAC91DB803E
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:39:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98DA21DB803A
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:39:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/10] vmscan: move priority variable into scan_control
In-Reply-To: <20100526102330.GL29038@csn.ul.ie>
References: <20100416224820.GE20640@cmpxchg.org> <20100526102330.GL29038@csn.ul.ie>
Message-Id: <20100528113404.7E18.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 11:39:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Hi

> Sorry for the long delay on this. I got distracted by the anon_vma and
> page migration stuff.

Sorry for the delay too. I don't have enough development time recently ;)
I had tested this patch series a while. but now they need to rebase and retest. that's sad.

> On Sat, Apr 17, 2010 at 12:48:20AM +0200, Johannes Weiner wrote:
> > On Thu, Apr 15, 2010 at 06:21:35PM +0100, Mel Gorman wrote:
> > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > 
> > > Now very lots function in vmscan have `priority' argument. It consume
> > > stack slightly. To move it on struct scan_control reduce stack.
> > 
> > I don't like this much because it obfuscates value communication.
> > 
> > Functions no longer have obvious arguments and return values, as it's all
> > passed hidden in that struct.
> > 
> > Do you think it's worth it?  I would much rather see that thing die than
> > expand on it...
> 
> I don't feel strongly enough to fight about it and reducing stack usage here
> isn't the "fix" anyway. I'll drop this patch for now.

I'm ok either.


> That aside, the page reclaim algorithm maintains a lot of state and the
> "priority" is part of that state. While the struct means that functions might
> not have obvious arguments, passing the state around as arguments gets very
> unwieldly very quickly. I don't think killing scan_control would be as
> nice as you imagine although I do think it should be as small as
> possible.

I don't have strong opinion. I think both you and Hannes were talking correct thing.
But Hannes seems to have more strong opinion. then, I'm tend to drop this one.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
