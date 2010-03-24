Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C97566B01FD
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 17:04:21 -0400 (EDT)
Date: Wed, 24 Mar 2010 16:03:03 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
In-Reply-To: <20100323190805.GH10659@random.random>
Message-ID: <alpine.DEB.2.00.1003241600001.16492@router.home>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random> <alpine.DEB.2.00.1003190812560.10759@router.home> <20100319144101.GB29874@random.random> <alpine.DEB.2.00.1003221027590.16606@router.home>
 <20100322170619.GQ29874@random.random> <alpine.DEB.2.00.1003231200430.10178@router.home> <20100323190805.GH10659@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010, Andrea Arcangeli wrote:

> On Tue, Mar 23, 2010 at 12:06:59PM -0500, Christoph Lameter wrote:
> > We can go to sleep in mprotect and mremap and wait for the breaking up to
> > be successful.
>
> Waiting for I/O in mprotect is functionally unacceptable to
> me. Userland would notice altered behavior.

If a delay is "altered behavior" then we should no longer run reclaim
because it "alters" the behavior of VM functions.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
