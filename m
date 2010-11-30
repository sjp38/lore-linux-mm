Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E6AF06B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 08:00:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAUD0ndT014905
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 22:00:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88F0445DE56
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:00:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 720D445DE4D
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:00:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 65BC5E08001
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:00:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31F751DB8037
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:00:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should get bonus
In-Reply-To: <alpine.DEB.2.00.1011271733460.3764@chino.kir.corp.google.com>
References: <20101123154843.7B8D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011271733460.3764@chino.kir.corp.google.com>
Message-Id: <20101130220107.8328.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Nov 2010 22:00:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 23 Nov 2010, KOSAKI Motohiro wrote:
> 
> > > > > I think in cases of heuristics like this where we obviously want to give 
> > > > > some bonus to CAP_SYS_ADMIN that there is consistency with other bonuses 
> > > > > given elsewhere in the kernel.
> > > > 
> > > > Keep comparision apple to apple. vm_enough_memory() account _virtual_ memory.
> > > > oom-killer try to free _physical_ memory. It's unrelated.
> > > > 
> > > 
> > > It's not unrelated, the LSM function gives an arbitrary 3% bonus to 
> > > CAP_SYS_ADMIN.  
> > 
> > Unrelated. LSM _is_ security module. and It only account virtual memory.
> > 
> 
> I needed a small bias for CAP_SYS_ADMIN tasks so I chose 3% since it's the 
> same proportion used elsewhere in the kernel and works nicely since the 
> badness score is now a proportion.  

Why? Is this important than X?

> If you'd like to propose a different 
> percentage or suggest removing the bias for root tasks altogether, feel 
> free to propose a patch.  Thanks!

I only need to revert bad change.


Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
