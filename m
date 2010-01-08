Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E9F86B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 19:26:55 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o080QqL3011852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 8 Jan 2010 09:26:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A1FD45DE54
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 09:26:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 45EEF45DE55
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 09:26:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F70F1DB803C
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 09:26:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C4E5B1DB805D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 09:26:51 +0900 (JST)
Date: Fri, 8 Jan 2010 09:23:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100108092333.1040c799.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1001071426590.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105054536.44bf8002@infradead.org>
	<alpine.DEB.2.00.1001050916300.1074@router.home>
	<20100105192243.1d6b2213@infradead.org>
	<alpine.DEB.2.00.1001071007210.901@router.home>
	<alpine.LFD.2.00.1001070814080.7821@localhost.localdomain>
	<1262884960.4049.106.camel@laptop>
	<alpine.LFD.2.00.1001070934060.7821@localhost.localdomain>
	<alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
	<alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
	<1262900683.4049.139.camel@laptop>
	<alpine.LFD.2.00.1001071426590.7821@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 14:33:50 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Thu, 7 Jan 2010, Peter Zijlstra wrote:
> >
> > I haven't yet looked at the patch, but isn't expand_stack() kinda like
> > what you want? That serializes using anon_vma_lock().
> 
> Yeah, that sounds like the right thing to do.  It is the same operation, 
> after all (and has the same effects, especially for the special case of 
> upwards-growing stacks).
> 
> So basically the idea is to extend that stack expansion to brk(), and 
> possibly mmap() in general.
> 
Hmm, do_brk() sometimes unmap conflicting mapping. Isn't it be a problem ?
Stack expansion just fails and SEGV if it hit with other mmaps....

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
