Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2E4938D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:24:22 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF0OJxq032282
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 09:24:19 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33FD545DE4D
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:24:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E73845DE6E
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:24:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC9391DB8041
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:24:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A341C1DB803E
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:24:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101109122817.BC5A.A69D9226@jp.fujitsu.com>
References: <20101109105801.BC30.A69D9226@jp.fujitsu.com> <20101109122817.BC5A.A69D9226@jp.fujitsu.com>
Message-Id: <20101115092238.BEEE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Nov 2010 09:24:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > Yes, I've tested it, and it deprecates the tunable as expected.  A single 
> > > warning message serves the purpose well: let users know one time without 
> > > being overly verbose that the tunable is deprecated and give them 
> > > sufficient time (2 years) to start using the new tunable.  That's how 
> > > deprecation is done.
> > 
> > no sense.
> > 
> > Why do their application need to rewrite for *YOU*? Okey, you will got
> > benefit from your new knob. But NOBDOY use the new one. and People need
> > to rewrite their application even though no benefit. 
> > 
> > Don't do selfish userland breakage!
> 
> And you said you ignore bug even though you have seen it. It suck!


At v2.6.36-rc1, oom-killer doesn't work at all because YOU BROKE.
And I was working on fixing it.

2010-08-19
http://marc.info/?t=128223176900001&r=1&w=2
http://marc.info/?t=128221532700003&r=1&w=2
http://marc.info/?t=128221532500008&r=1&w=2

However, You submitted new crap before the fixing. 

2010-08-15
http://marc.info/?t=128184669600001&r=1&w=2

If you tested mainline a bit, you could find the problem quickly.
You should have fixed mainline kernel at first.


	Again, YOU HAVEN'T TESTED YOUR OWN PATCH AT ALL.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
