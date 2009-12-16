Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1CF6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 05:11:15 -0500 (EST)
Date: Wed, 16 Dec 2009 11:11:07 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091216101107.GA15031@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Dec 16, 2009 at 12:00:11PM +0900, KAMEZAWA Hiroyuki wrote:
> This is from Christoph Lameter's mm_accessor patch posted 5/Nov.
> 
> Replacing all access to mm->mmap_sem with mm-accessor functions as
>  mm_read_lock,
>  mm_write_lock,
>  etc...
> 
> This kind of function allows us to improve page fault performance etc..
> For example, skil down_read(mmap_sem) in some situation.
> (as: http://marc.info/?l=linux-mm&m=125809791306459&w=2)

The problem is that it also slows down the writers, and we have
some workloads where writing is the bottleneck.

I don't think this is the right trade off at this time.

Also the patches didn't fare too well in testing unfortunately.

I suspect we'll rather need multiple locks split per address
space range.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
