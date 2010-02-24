Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 03AC46B0078
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:29:27 -0500 (EST)
Message-ID: <4B858BFC.8020801@redhat.com>
Date: Wed, 24 Feb 2010 15:28:44 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 36/36] khugepaged
References: <20100221141009.581909647@redhat.com>	<20100221141758.658303189@redhat.com> <20100224121111.232602ba.akpm@linux-foundation.org>
In-Reply-To: <20100224121111.232602ba.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/24/2010 03:11 PM, Andrew Morton wrote:
> On Sun, 21 Feb 2010 15:10:45 +0100 aarcange@redhat.com wrote:
>
>> Add khugepaged to relocate fragmented pages into hugepages if new hugepages
>> become available. (this is indipendent of the defrag logic that will have to
>> make new hugepages available)
>
> What does this mean?  What are the user-visible effects if (when) this
> kernel thread fails to keep up?

The result will be that applications use small pages, instead of
large ones, and potentially run slightly slower.

The same kind of slowdowns that memory pressure can already cause
to userland processes.

> Generally it seems like a bad idea to do this sort of thing
> asynchronously.  Because it reduces repeatability across runs and
> across machines - system behaviour becomes more dependent on the size
> of the machine and the amount of activity in unrelated jobs?

Isn't system performance already dependent on the size of
the machine and the amount of activity in unrelated jobs?

Using hugepages is a performance enhancement only and
otherwise transparent to userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
