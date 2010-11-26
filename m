Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 68A598D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 10:48:18 -0500 (EST)
Date: Fri, 26 Nov 2010 09:48:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101125101803.F450.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011260943220.12265@router.home>
References: <20101124092753.GS19571@csn.ul.ie> <20101124191749.GA29511@hostway.ca> <20101125101803.F450.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Nov 2010, KOSAKI Motohiro wrote:
> Please try SLAB instead SLUB (it can be switched by kernel build option).
> SLUB try to use high order allocation implicitly.

SLAB uses orders 0-1. Order is fixed per slab cache and determined based
on object size at slab creation.

SLUB uses orders 0-3. Falls back to smallest order if alloc order cannot
be met by the page allocator.

One can reduce SLUB to SLAB orders by specifying the following kernel
commandline parameter:

slub_max_order=1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
