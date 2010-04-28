Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 713556B01F6
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 20:40:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S0ekeu006504
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 09:40:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A8745DE70
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:40:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FAD945DE4D
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:40:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F5161DB803A
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:40:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6C091DB803F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:40:42 +0900 (JST)
Date: Wed, 28 Apr 2010 09:36:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428093642.ca869815.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100428000833.GE510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
	<20100428090302.5e69721f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100428000833.GE510@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 02:08:33 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Apr 28, 2010 at 09:03:02AM +0900, KAMEZAWA Hiroyuki wrote:
> > I bet calling __get_user_pages_fast() before vma_adjust() is the way to go. 
> > When page_count(page) != page_mapcount(page) +1, migration skip it.
> 
> My proposed fix avoids to walk the pagetables once more time and to
> mangle over the page counts. Can you check it? It works but it needs
> more review.

Sure...but can we avoid temporal objrmap breakage(inconsistency) by it ?

THanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
