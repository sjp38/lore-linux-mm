Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BFC9D6B0210
	for <linux-mm@kvack.org>; Tue, 18 May 2010 21:06:27 -0400 (EDT)
Date: Wed, 19 May 2010 03:05:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH -v2 5/5] extend KSM refcounts to the anon_vma root
Message-ID: <20100519010558.GK25903@random.random>
References: <20100512134111.467fb6c2@annuminas.surriel.com>
 <20100512210706.GQ24989@csn.ul.ie>
 <4BEB18FE.1090808@redhat.com>
 <20100513112603.GB27949@csn.ul.ie>
 <4BEBFA82.2000301@redhat.com>
 <20100513132436.GC27949@csn.ul.ie>
 <20100513103446.7eecd5b9@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513103446.7eecd5b9@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 10:34:46AM -0400, Rik van Riel wrote:
> +		int empty list_empty(&anon_vma->head);

Adding "=" and hope it all works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
