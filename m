Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 121DA6B007E
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 16:57:39 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every single munmap
References: <20120223145417.261225fd@cuia.bos.redhat.com>
	<20120223150034.2c757b3a@cuia.bos.redhat.com>
Date: Thu, 23 Feb 2012 13:57:42 -0800
In-Reply-To: <20120223150034.2c757b3a@cuia.bos.redhat.com> (Rik van Riel's
	message of "Thu, 23 Feb 2012 15:00:34 -0500")
Message-ID: <m2vcmxp609.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

Rik van Riel <riel@redhat.com> writes:

> Some programs have a large number of VMAs, and make frequent calls
> to mmap and munmap. Having munmap constantly cause the search
> pointer for get_unmapped_area to get reset can cause a significant
> slowdown for such programs. 

This would be a much nicer patch if you split it into one that merges
all the copy'n'paste code and another one that actually implements
the new algorithm.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
