Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C01796B0044
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 18:52:13 -0500 (EST)
Message-ID: <4B467388.809@redhat.com>
Date: Thu, 07 Jan 2010 18:51:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105054536.44bf8002@infradead.org>  <alpine.DEB.2.00.1001050916300.1074@router.home>  <20100105192243.1d6b2213@infradead.org>  <alpine.DEB.2.00.1001071007210.901@router.home>  <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 01/07/2010 12:36 PM, Linus Torvalds wrote:
> On Thu, 7 Jan 2010, Peter Zijlstra wrote:
>>
>> Right, supposing we can make this speculative fault stuff work, then we
>> can basically reduce the mmap_sem usage in fault to:
>>
>>    - allocating new page tables
>>    - extending the growable vmas
>>
>> And do everything else without holding it, including zeroing and IO.
>
> Well, I have yet to hear a realistic scenario of _how_ to do it all
> speculatively in the first place, at least not without horribly subtle
> complexity issues. So I'd really rather see how far we can possibly get by
> just improving mmap_sem.

I would like to second this sentiment.  I am trying to make the
anon_vma and rmap bits more scalable for multi-process server
workloads and it is quite worrying how complex locking already
is.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
