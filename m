Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6240C6B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 11:30:12 -0400 (EDT)
Date: Wed, 28 Oct 2009 16:30:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028153000.GE9640@random.random>
References: <20091026185130.GC4868@random.random>
 <87ljiwk8el.fsf@basil.nowhere.org>
 <20091027193007.GA6043@random.random>
 <20091028042805.GJ7744@basil.fritz.box>
 <20091028120050.GD9640@random.random>
 <20091028141803.GQ7744@basil.fritz.box>
 <1256741656.5613.15.camel@aglitke>
 <20091028151302.GR7744@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028151302.GR7744@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 04:13:02PM +0100, Andi Kleen wrote:
> it simply won't be able to use Andrea's transparent code until
> someone fixes the MMU. Doesn't seem a disaster

Well at least we found a good reason for hugetlbfs that forces
hugepages on the whole vma to still exist... Even without
split_huge_page (assuming all code would be hugepage aware) the
requirement is that if a hugepage allocation fails we _gracefully_
fallback to 4k allocations and we mix those in the same vma with other
hugepages (so the daemon can collapse the 4k pages into a hugepage
later when they become available).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
