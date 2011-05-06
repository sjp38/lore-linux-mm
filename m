Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2664B6B0024
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:07:21 -0400 (EDT)
Date: Fri, 6 May 2011 20:06:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH]mm/page_alloc.c: no need del from lru
Message-ID: <20110506180646.GF6330@random.random>
References: <1304694099.2450.3.camel@figo-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304694099.2450.3.camel@figo-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujisu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@osdl.org>

Hello,

On Fri, May 06, 2011 at 11:01:21PM +0800, Figo.zhang wrote:
> 
> split_free_page() the page is still free page, it is no need del from lru.

This is in the buddy freelist, see the other list_add in
page_alloc.c. It's not the lru as in release_pages. I see little
chance that if this was wrong it could go unnoticed so long without
major mm corruption reported. Removing it also should result in heavy
mm corruption.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
