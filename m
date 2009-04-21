Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1356B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:47:46 -0400 (EDT)
Date: Tue, 21 Apr 2009 09:48:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 13/25] Inline __rmqueue_smallest()
Message-ID: <20090421084827.GF12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-14-git-send-email-mel@csn.ul.ie> <1240300695.771.54.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240300695.771.54.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 10:58:15AM +0300, Pekka Enberg wrote:
> On Mon, 2009-04-20 at 23:19 +0100, Mel Gorman wrote:
> > Inline __rmqueue_smallest by altering flow very slightly so that there
> > is only one call site. This allows the function to be inlined without
> > additional text bloat.
> 
> Quite frankly, I think these patch changelogs could use some before and
> after numbers for "size mm/page_alloc.o" because it's usually the case
> that kernel text shrinks when you _remove_ inlines.
> 

I can generate that although it'll be a bit misleading because stack
parameters are added earlier in the series that get eliminated later due
to inlines. Shuffling them around won't help a whole lot.

Inline for only one call site though saves text in this series. For a
non-inlined function, the calling convension has to be obeyed and for a
large number of parameters like this functions, that can be sizable.

I'll regenerate the figures though.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
