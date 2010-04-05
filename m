Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D7BE46B01E3
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 17:19:19 -0400 (EDT)
Message-ID: <4BBA53A0.8050608@redhat.com>
Date: Tue, 06 Apr 2010 00:18:24 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <20100405210133.GE21620@think>
In-Reply-To: <20100405210133.GE21620@think>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/06/2010 12:01 AM, Chris Mason wrote:
> On Mon, Apr 05, 2010 at 01:32:21PM -0700, Linus Torvalds wrote:
>    
>>
>> On Mon, 5 Apr 2010, Pekka Enberg wrote:
>>      
>>> AFAIK, most modern GCs split memory in young and old generation
>>> "zones" and _copy_ surviving objects from the former to the latter if
>>> their lifetime exceeds some threshold. The JVM keeps scanning the
>>> smaller young generation very aggressively which causes TLB pressure
>>> and scans the larger old generation less often.
>>>        
>> .. my only input to this is: numbers talk, bullsh*t walks.
>>
>> I'm not interested in micro-benchmarks, either. I can show infinite TLB
>> walk improvement in a microbenchmark.
>>      
> Ok, I'll bite.  I should be able to get some database workloads with
> hugepages, transparent hugepages, and without any hugepages at all.
>    

Please run them in conjunction with Mel Gorman's memory compaction, 
otherwise fragmentation may prevent huge pages from being instantiated.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
