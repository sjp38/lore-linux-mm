Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B55EC6B0232
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 13:23:47 -0400 (EDT)
Date: Fri, 26 Mar 2010 18:23:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 35 of 41] don't leave orhpaned swap cache after ksm
 merging
Message-ID: <20100326172321.GA5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <6a19c093c020d009e736.1269622839@v2.random>
 <4BACEBF8.90909@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BACEBF8.90909@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 01:16:40PM -0400, Rik van Riel wrote:
> On 03/26/2010 01:00 PM, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli<aarcange@redhat.com>
> >
> > When swapcache is replaced by a ksm page don't leave orhpaned swap cache.
> 
> Why is this part of the hugepage series?

This is a not relevant for hugepages. There's another ksm change so I
thought I could sneak it in. It's still separated so it can be pulled
off separately as needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
