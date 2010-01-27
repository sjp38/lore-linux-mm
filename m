Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B92166B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 16:46:50 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
Date: Wed, 27 Jan 2010 22:44:47 +0100
References: <patchbomb.1264513915@v2.random> <da09747e3b1d0368a0a6.1264513916@v2.random> <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001272244.47211.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 27 January 2010, Hugh Dickins wrote:
> So I think you should follow what we did with MADV_MERGEABLE:
> define it in asm-generic/mman-common.h and the four arches,
> use the expected number 14 wherever you can, and 67 for parisc.
> 
> Or if you feel there's virtue in using the same number on all
> arches (it would be less confusing, yes) and want to pave that way
> (as we'd have better done with MADV_MERGEABLE), add a comment into
> four of those files to point to parisc's peculiar group, and use
> the same number 67 on all (perhaps via an asm-generic/madv-common.h).
> 
> I'd take the lazy way out and follow what we did with MADV_MERGEABLE,
> unless Arnd (Mr Asm-Generic) would prefer something else.

I fully agree with using 14 in asm-generic and 67 in parisc.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
