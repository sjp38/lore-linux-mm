Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7140B6004C0
	for <linux-mm@kvack.org>; Sat,  1 May 2010 21:56:52 -0400 (EDT)
Date: Sat, 1 May 2010 20:56:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
In-Reply-To: <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1005012055010.2663@router.home>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Apr 2010, Mel Gorman wrote:

> There is a race between shift_arg_pages and migration that triggers this bug.
> A temporary stack is setup during exec and later moved. If migration moves
> a page in the temporary stack and the VMA is then removed before migration
> completes, the migration PTE may not be found leading to a BUG when the
> stack is faulted.

A simpler solution would be to not allow migration of the temporary stack?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
