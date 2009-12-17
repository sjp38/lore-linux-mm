Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D605E6B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 15:47:49 -0500 (EST)
Message-ID: <4B2A98E6.5080406@sgi.com>
Date: Thu, 17 Dec 2009 12:47:34 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com>
In-Reply-To: <4B2A8D83.30305@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



Rik van Riel wrote:
> Christoph Lameter wrote:
>> Would it be possible to start out with a version of huge page support 
>> that
>> does not require the complex splitting and joining of huge pages?
>>
>> Without that we would not need additional refcounts.
>>
>> Maybe a patch to allow simply the use of anonymous huge pages without a
>> hugetlbfs mmap in the middle? IMHO its useful even if we cannot swap it
>> out.
> 
> Christoph, we need a way to swap these anonymous huge
> pages.  You make it look as if you just want the
> anonymous huge pages and a way to then veto any attempts
> to make them swappable (on account of added overhead).

On very large SMP systems with huge amounts of memory, the
gains from huge pages will be significant.  And swapping
will not be an issue.  I agree that the two should be
split up and perhaps even make swapping an option?

> 
> I believe it will be more useful if we figure out a way
> forward together.  Do you have any ideas on how to solve
> the hugepage swapping problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
