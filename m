Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 78C8E6B01F3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 11:14:43 -0400 (EDT)
Date: Thu, 22 Apr 2010 10:14:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
  pages
In-Reply-To: <1271946226.2100.211.camel@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1004221009150.32107@router.home>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>  <alpine.DEB.2.00.1004210927550.4959@router.home>  <20100421150037.GJ30306@csn.ul.ie>  <alpine.DEB.2.00.1004211004360.4959@router.home>  <20100421151417.GK30306@csn.ul.ie>
 <alpine.DEB.2.00.1004211027120.4959@router.home>  <20100421153421.GM30306@csn.ul.ie>  <alpine.DEB.2.00.1004211038020.4959@router.home>  <20100422092819.GR30306@csn.ul.ie>  <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
 <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>  <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>  <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <1271946226.2100.211.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, Minchan Kim wrote:

> For further optimization, we can hold vma->adjust_lock if vma_address
> returns -EFAULT. But I hope we redesigns it without new locking.
> But I don't have good idea, now. :(

You could make it atomic through the use of RCU.

Create a new vma entry with the changed parameters and then atomically
switch to the new vma.

Problem is that you have some list_heads in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
