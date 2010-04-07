Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5427E6B01F4
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:06:10 -0400 (EDT)
Date: Tue, 6 Apr 2010 17:05:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/14] Export fragmentation index via
 /proc/extfrag_index
Message-Id: <20100406170542.fe9b9f33.akpm@linux-foundation.org>
In-Reply-To: <1270224168-14775-7-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-7-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  2 Apr 2010 17:02:40 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Fragmentation index is a value that makes sense when an allocation of a
> given size would fail. The index indicates whether an allocation failure is
> due to a lack of memory (values towards 0) or due to external fragmentation
> (value towards 1).  For the most part, the huge page size will be the size
> of interest but not necessarily so it is exported on a per-order and per-zone
> basis via /proc/extfrag_index

(/proc/sys/vm?)

Like unusable_index, this seems awfully specialised.  Perhaps we could
hide it under CONFIG_MEL, or even put it in debugfs with the intention
of removing it in 6 or 12 months time.  Either way, it's hard to
justify permanently adding this stuff to every kernel in the world?


I have a suspicion that all the info in unusable_index and
extfrag_index could be computed from userspace using /proc/kpageflags
(and perhaps a bit of dmesg-diddling to find the zones).  If that can't
be done today, I bet it'd be pretty easy to arrange for it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
