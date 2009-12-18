Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E17296B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 07:53:42 -0500 (EST)
Message-ID: <4B2B7B11.5010207@redhat.com>
Date: Fri, 18 Dec 2009 14:52:33 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com>
In-Reply-To: <4B2A8D83.30305@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 12/17/2009 09:58 PM, Rik van Riel wrote:
>> Maybe a patch to allow simply the use of anonymous huge pages without a
>> hugetlbfs mmap in the middle? IMHO its useful even if we cannot swap it
>> out.
>
>
> Christoph, we need a way to swap these anonymous huge
> pages.  You make it look as if you just want the
> anonymous huge pages and a way to then veto any attempts
> to make them swappable (on account of added overhead).

On top of swap, we want ballooning and samepage merging to work with 
large pages.

As others have noted, swap may come back into fashion using ssds 
(assuming ssds are significantly cheaper than RAM).

There is also ramzswap which is plenty fast.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
