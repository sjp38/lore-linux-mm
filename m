Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 03EDA8D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:07:14 -0500 (EST)
Date: Wed, 26 Jan 2011 15:06:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
Message-Id: <20110126150612.cf288843.akpm@linux-foundation.org>
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 01:17:05 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> In some cases migrate_pages could return zero while still leaving a
> few pages in the pagelist (and some caller wouldn't notice it has to
> call putback_lru_pages after commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab).
> 
> Add one missing putback_lru_pages not added by commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab.
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Some patch administrivia:

a) you were on the delivery path for this patch, so you should have
   added your signed-off-by:.  I have made that change to my copy.

   There's no harm in also having a Reviewed-by:, but Signed-off-by:
   does imply that, we hope.

b) Andrea's From: line appeared twice.

c) Please choose patch titles which identify the subsystem which is
   being patched.  Plain old "mm:" will suit, although "mm:
   compaction:" or "mm/compaction" would be nicer.

   For some weird reason people keep on sending me patches with titles like

	drivers: mmc: host: omap.c: frob the nozzle

   or similar.  I think there might be some documentation file which
   (mis)leads them to do this.  I simply do the utterly obvious and
   convert it to

	drivers/mmc/host/omap.c: frob the nozzle

   duh.

d) Please don't identify patches via bare commit IDs.  Because
   commits can have different IDs in different trees.  Instead use the
   form cf608ac19c95 ("mm: compaction: fix COMPACTPAGEFAILED
   counting").  I end up having to do this operation multiple times a
   day and it's dull.  And sometimes I don't even have that commit ID
   in any of my trees, because they were working against some other
   tree.

   Also note that the 40-character commit ID has been trimmed to 12
   characters or so.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
