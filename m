Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B36946B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 00:29:35 -0500 (EST)
Received: by iwn41 with SMTP id 41so14342387iwn.12
        for <linux-mm@kvack.org>; Sat, 09 Jan 2010 21:29:34 -0800 (PST)
Message-ID: <4B496546.5010607@vflare.org>
Date: Sun, 10 Jan 2010 10:57:34 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
References: <20100104182429.833180340@chello.nl> <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain> <1262969610.4244.36.camel@laptop> <201001090947.57479.edt@aei.ca>
In-Reply-To: <201001090947.57479.edt@aei.ca>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ed Tomlinson <edt@aei.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 01/09/2010 08:17 PM, Ed Tomlinson wrote:
> On Friday 08 January 2010 11:53:30 Peter Zijlstra wrote:
>> On Tue, 2010-01-05 at 20:20 -0800, Linus Torvalds wrote:
>>>
>>> On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
>>>>>
>>>>> Of course, your other load with MADV_DONTNEED seems to be horrible, and 
>>>>> has some nasty spinlock issues, but that looks like a separate deal (I 
>>>>> assume that load is just very hard on the pgtable lock).
>>>>
>>>> It's zone->lock, I guess. My test program avoids pgtable lock problem.
>>>
>>> Yeah, I should have looked more at your callchain. That's nasty. Much 
>>> worse than the per-mm lock. I thought the page buffering would avoid the 
>>> zone lock becoming a huge problem, but clearly not in this case.
>>
>> Right, so I ran some numbers on a multi-socket (2) machine as well:
>>
>>                                pf/min
>>
>> -tip                          56398626
>> -tip + xadd                  174753190
>> -tip + speculative           189274319
>> -tip + xadd + speculative    200174641
> 
> Has anyone tried these patches with ramzswap?  Nitin do they help with the locking
> issues you mentioned?
> 

Locking problem with ramzswap seems completely unrelated to what is being discussed here.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
