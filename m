Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3B0600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 13:00:35 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
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
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jan 2010 19:00:07 +0100
Message-ID: <1262887207.4049.127.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-07 at 09:49 -0800, Linus Torvalds wrote:
> 
> The thing is, I can pretty much _guarantee_ that the speculative page 
> fault is going to end up doing a lot of nasty stuff that still needs 
> almost-global locking, and it's likely to be more complicated and slower 
> for the single-threaded case (you end up needing refcounts, a new "local" 
> lock or something).

Well, with that sync_vma() thing I posted the other day all the
speculative page fault needs is a write to current->fault_vma, the ptl
and an O(nr_threads) loop on unmap() for file vmas -- aside from writing
the pte itself of course.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
