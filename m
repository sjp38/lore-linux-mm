Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9485F600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:00:09 -0500 (EST)
Date: Mon, 4 Jan 2010 10:58:41 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
In-Reply-To: <20100103183802.GA11420@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1001041058120.7191@router.home>
References: <patchbomb.1261076403@v2.random> <4d96699c8fb89a4a22eb.1261076428@v2.random> <20091218200345.GH21194@csn.ul.ie> <20091219164143.GC29790@random.random> <20091221203149.GD23345@csn.ul.ie> <20091223000640.GI6429@random.random>
 <20100103183802.GA11420@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

On Sun, 3 Jan 2010, Mel Gorman wrote:

> I prototyped memory deframentation ages ago. It worked for the most case
> but has bit-rotted significantly. I really should dig it out from
> whatever hole I left it in.

Yes please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
