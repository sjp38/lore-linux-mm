Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A25306B007B
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 12:01:14 -0500 (EST)
Message-ID: <4B2BB52A.7050103@redhat.com>
Date: Fri, 18 Dec 2009 19:00:26 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
References: <20091217084046.GA9804@basil.fritz.box> <1261039534.27920.67.camel@laptop> <20091217085430.GG9804@basil.fritz.box> <20091217144551.GA6819@linux.vnet.ibm.com> <20091217175338.GL9804@basil.fritz.box> <20091217190804.GB6788@linux.vnet.ibm.com> <20091217195530.GM9804@basil.fritz.box> <alpine.DEB.2.00.0912171356020.4640@router.home> <1261080855.27920.807.camel@laptop> <alpine.DEB.2.00.0912171439380.4640@router.home> <20091218051754.GC417@elte.hu>
In-Reply-To: <20091218051754.GC417@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/18/2009 07:17 AM, Ingo Molnar wrote:
>
>> It is not about naming. The accessors hide the locking mechanism for
>> mmap_sem. Then you can change the locking in a central place.
>>
>> The locking may even become configurable later. Maybe an embedded solution
>> will want the existing scheme but dual quad socket may want a distributed
>> reference counter to avoid bouncing cachelines on faults.
>>      
> Hiding the locking is pretty much the worst design decision one can make.
>
>    

It does allow incremental updates.  For example if we go with range 
locks, the accessor turns into a range lock of the entire address space; 
users can be converted one by one to use their true ranges in order of 
importance.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
