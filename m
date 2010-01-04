Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5AD7F6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 18:21:07 -0500 (EST)
Message-ID: <4B4277B0.1080506@redhat.com>
Date: Mon, 04 Jan 2010 18:20:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/8] Speculative pagefault -v3
References: <20100104182429.833180340@chello.nl>	 <4B42606F.3000906@redhat.com> <1262641573.6408.434.camel@laptop>
In-Reply-To: <1262641573.6408.434.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 01/04/2010 04:46 PM, Peter Zijlstra wrote:
> On Mon, 2010-01-04 at 16:41 -0500, Rik van Riel wrote:
>> On 01/04/2010 01:24 PM, Peter Zijlstra wrote:
>>> Patch series implementing speculative page faults for x86.
>>
>> Fun, but why do we need this?
>
> People were once again concerned with mmap_sem contention on threaded
> apps on large machines. Kame-san posted some patches, but I felt they
> weren't quite crazy enough ;-)

In that case, I assume that somebody else (maybe Kame-san or
Christoph) will end up posting a benchmark that shows how
these patches help.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
