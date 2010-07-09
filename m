Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 965446B02A4
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 21:31:25 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o691VM2I019235
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 10:31:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id ADFA545DE54
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:31:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E54945DE63
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:31:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D0DC1DB803F
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:31:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 395111DB805A
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:31:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <1278588200.1900.89.camel@laptop>
References: <20100708200324.CD4B.A69D9226@jp.fujitsu.com> <1278588200.1900.89.camel@laptop>
Message-Id: <20100709102430.CD65.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri,  9 Jul 2010 10:31:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-07-08 at 20:06 +0900, KOSAKI Motohiro wrote:
> > > [ small note on that we really should kill __GFP_NOFAIL, its utter
> > > deadlock potential ]
> > 
> > I disagree. __GFP_NOFAIL mean this allocation failure can makes really
> > dangerous result. Instead, OOM-Killer should try to kill next process.
> > I think. 
> 
> Say _what_?! you think NOFAIL is a sane thing? 

insane obviously ;)
but as far as my experience, some embedded system prefer to use NOFAIL.
So, I don't like to make big hammer crash. NOFAIL killing need long year
rather than you expected, I guess.


> Pretty much everybody has
> been agreeing for years that the thing should die.

I'm not against this at all. but until it die, it should works correctly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
