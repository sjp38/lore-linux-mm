Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 797356B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:58:30 -0500 (EST)
Message-ID: <4B8592BB.1040007@redhat.com>
Date: Wed, 24 Feb 2010 15:57:31 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 36/36] khugepaged
References: <20100221141009.581909647@redhat.com>	<20100221141758.658303189@redhat.com>	<20100224121111.232602ba.akpm@linux-foundation.org>	<4B858BFC.8020801@redhat.com> <20100224125253.2edb4571.akpm@linux-foundation.org>
In-Reply-To: <20100224125253.2edb4571.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/24/2010 03:52 PM, Andrew Morton wrote:
> On Wed, 24 Feb 2010 15:28:44 -0500 Rik van Riel<riel@redhat.com>  wrote:
>
>>> Generally it seems like a bad idea to do this sort of thing
>>> asynchronously.  Because it reduces repeatability across runs and
>>> across machines - system behaviour becomes more dependent on the size
>>> of the machine and the amount of activity in unrelated jobs?
>>
>> Isn't system performance already dependent on the size of
>> the machine and the amount of activity in unrelated jobs?
>
> I said "repeatability".
>
>> Using hugepages is a performance enhancement only and
>> otherwise transparent to userspace.
>
> And it's bad that a job run will take a varying amount of CPU time due
> to unrelated activity.  Yes, that can already happen, but it's
> undesirable and it's undesirable to worsen things.
>
> If this work could be done synchronously then runtimes become more
> consistent, which is a good thing.

Only if it means run times become shorter...

I would argue that running consistently slower would
be worse than running inconsitently faster, but maybe
that's just me :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
