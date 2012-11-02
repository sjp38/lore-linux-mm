Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 253F16B0068
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 22:26:18 -0400 (EDT)
Date: Fri, 2 Nov 2012 11:32:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] Support volatile range for anon vma
Message-ID: <20121102023220.GA3326@bbox>
References: <1351133820-14096-1-git-send-email-minchan@kernel.org>
 <0000013a9881a86c-c0fb5823-b6e7-4bea-8707-f6b8eddae14d-000000@email.amazonses.com>
 <20121026005851.GD15767@bbox>
 <0000013abda6fc7d-6cfbef1e-bc7d-4f4f-bb38-221729e8c9f9-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013abda6fc7d-6cfbef1e-bc7d-4f4f-bb38-221729e8c9f9-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Christoph,

On Thu, Nov 01, 2012 at 08:26:09PM +0000, Christoph Lameter wrote:
> On Fri, 26 Oct 2012, Minchan Kim wrote:
> 
> > I guess it would improve system performance very well.
> > But as I wrote down in description, downside of the patch is that we have to
> > age anon lru although we don't have swap. But gain via the patch is bigger than
> > loss via aging of anon lru when memory pressure happens. I don't see other downside
> > other than it. What do you think about it?
> > (I didn't implement anon lru aging in case of no-swap but it's trivial
> > once we decide)
> 
> 
> I am a bit confused like some of the others as to why this patch is
> necessary since we already have DONT_NEED.

Totally, my fault. I should have written clearly.

DONT_NEED have to zap all pte entries/tlb flush when system call
happens so DONT_NEED isn't cheap.
Even, later if user accesses address again, page fault happens.

This patch is to remove above two overheads.
while I discussed with KOSAKI, I found there was trial of simillar
goal by Rik. https://lkml.org/lkml/2007/4/17/53
But as I look over the code, it seems to have a cost about setting PG_lazyfree
on all pages of range which isn't in my implementation.

Anyway, I would like to know where Rik's patch wasn't merged at that time.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
