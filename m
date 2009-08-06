Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E2BF76B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 09:09:27 -0400 (EDT)
Message-ID: <4A7AD5DF.7090801@redhat.com>
Date: Thu, 06 Aug 2009 09:08:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random>
In-Reply-To: <20090806100824.GO23385@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> Likely we need a cut-off point, if we detect it takes more than X
> seconds to scan the whole active list, we start ignoring young bits,

We could just make this depend on the calculated inactive_ratio,
which depends on the size of the list.

For small systems, it may make sense to make every accessed bit
count, because the working set will often approach the size of
memory.

On very large systems, the working set may also approach the
size of memory, but the inactive list only contains a small
percentage of the pages, so there is enough space for everything.

Say, if the inactive_ratio is 3 or less, make the accessed bit
on the active lists count.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
