Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1DFA96001DA
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 13:03:37 -0500 (EST)
Message-ID: <4B82C6D2.8010201@redhat.com>
Date: Mon, 22 Feb 2010 20:02:58 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 25/36] _GFP_NO_KSWAPD
References: <20100221141009.581909647@redhat.com> <20100221141756.772875923@redhat.com> <4B82C487.9020407@redhat.com> <20100222180009.GM11504@random.random>
In-Reply-To: <20100222180009.GM11504@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/22/2010 08:00 PM, Andrea Arcangeli wrote:
> On Mon, Feb 22, 2010 at 12:53:11PM -0500, Rik van Riel wrote:
>    
>> Once Mel's defragmentation code is in, we can kick off
>> that code instead when a hugepage allocation fails.
>>      
> That will be cool yes!! Then maybe we can turn on defrag by
> default... (maybe because it'd still slowdown the allocation time)
>
> I think at least for khugepaged invoking memory compaction code by
> default is going to be good idea. And then I wonder if it makes sense
> to allow the user to disable defrag in khugepaged, if yes then it'd
> require a new sysfs file in the khugepaged directory.
>    

If we detect hugepage pressure, we can run compaction in a separate 
thread, so we can have low latency allocations.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
