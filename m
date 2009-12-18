Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DAC436B0062
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 11:05:16 -0500 (EST)
Date: Fri, 18 Dec 2009 17:04:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-ID: <20091218160437.GP29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <d9c8d2160feb7d82736b.1261076431@v2.random>
 <20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 10:33:12AM +0900, KAMEZAWA Hiroyuki wrote:
> Then, maybe we (I?) should cut this part (and some from 27/28) out and
> merge into memcg. It will be helpful to all your work.

You can't merge this part, huge_memory.c is not there yet. But you
should merge 27/28 instead, that one is self contained.

> But I don't like a situation which memcg's charge are filled with _locked_ memory.

There's no locked memory here. It's all swappable.

> (Especially, bad-configured softlimit+hugepage will adds much regression.)
> New counter as "usage of huge page" will be required for memcg, at least.

no, hugepages are fully transparent and userland can't possibly know
if it's running on hugepages or regular pages. The only difference is
in userland going faster, everything else is identical so there's no
need of any other memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
