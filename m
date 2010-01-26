Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E9746B0089
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 19:53:09 -0500 (EST)
Message-ID: <4B5E3CC0.2060006@redhat.com>
Date: Mon, 25 Jan 2010 19:52:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home>
In-Reply-To: <alpine.DEB.2.00.1001251529070.5379@router.home>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 01/25/2010 04:50 PM, Christoph Lameter wrote:

> So its not possible to use these "huge" pages in a useful way inside of
> the kernel. They are volatile and temporary.

> In short they cannot be treated as 2M entities unless we add some logic to
> prevent splitting.
>
> Frankly this seems to be adding splitting that cannot be used if one
> really wants to use large pages for something.

What exactly do you need the stable huge pages for?

Do you have anything specific in mind that we should take
into account?

Want to send in an incremental patch that can temporarily block
the pageout code from splitting up a huge page, so your direct
users of huge pages can rely on them sticking around until the
transaction is done?

> I still think we should get transparent huge page support straight up
> first without complicated fallback schemes that makes huge pages difficult
> to use.

Without swapping, they will become difficult to use for system
administrators, at least in the workloads we care about.

I understand that your workloads may be different.

Please tell us what you need, instead of focussing on what you
don't want, and we may be able to keep the code in such a shape
that you can easily add your functionality.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
