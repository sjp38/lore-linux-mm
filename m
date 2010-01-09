Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFA96B003D
	for <linux-mm@kvack.org>; Sat,  9 Jan 2010 10:52:56 -0500 (EST)
Date: Sat, 9 Jan 2010 07:55:17 -0800
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-ID: <20100109075517.4ec65b7e@infradead.org>
In-Reply-To: <alpine.DEB.2.00.1001080946390.23727@router.home>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105054536.44bf8002@infradead.org>
	<alpine.DEB.2.00.1001050916300.1074@router.home>
	<20100105192243.1d6b2213@infradead.org>
	<alpine.DEB.2.00.1001071007210.901@router.home>
	<alpine.LFD.2.00.1001070814080.7821@localhost.localdomain>
	<alpine.DEB.2.00.1001071025450.901@router.home>
	<20100107204940.253ed753@infradead.org>
	<alpine.DEB.2.00.1001080946390.23727@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jan 2010 09:51:49 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 7 Jan 2010, Arjan van de Ven wrote:
> 
> > if an app has to change because our kernel sucks (for no good
> > reason), "change the app" really is the lame type of answer.
> 
> We are changing apps all of the time here to reduce the number of
> system calls. 

it's fine to fix an app for something fundamental.
it sucks to need to fix an app because we decided to clear a page
inside a lock rather than outside it.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
