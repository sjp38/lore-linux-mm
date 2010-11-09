Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DE78E6B00BF
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 22:28:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA93SBXR031674
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 12:28:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0D0145DE4F
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:28:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8387945DE4E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:28:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6519CE18004
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:28:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13198E08001
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:28:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101109105801.BC30.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com> <20101109105801.BC30.A69D9226@jp.fujitsu.com>
Message-Id: <20101109122817.BC5A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 12:28:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Yes, I've tested it, and it deprecates the tunable as expected.  A single 
> > warning message serves the purpose well: let users know one time without 
> > being overly verbose that the tunable is deprecated and give them 
> > sufficient time (2 years) to start using the new tunable.  That's how 
> > deprecation is done.
> 
> no sense.
> 
> Why do their application need to rewrite for *YOU*? Okey, you will got
> benefit from your new knob. But NOBDOY use the new one. and People need
> to rewrite their application even though no benefit. 
> 
> Don't do selfish userland breakage!

And you said you ignore bug even though you have seen it. It suck!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
