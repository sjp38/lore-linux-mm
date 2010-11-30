Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0EB326B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:13:55 -0500 (EST)
Date: Tue, 30 Nov 2010 13:13:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101130091325.GA17340@hostway.ca>
Message-ID: <alpine.DEB.2.00.1011301311530.3134@router.home>
References: <20101124092753.GS19571@csn.ul.ie> <20101124191749.GA29511@hostway.ca> <20101125101803.F450.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011260943220.12265@router.home> <20101130091325.GA17340@hostway.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Simon Kirby wrote:

> Can we also mess with these /sys files on the fly?

Sure. Go ahead. These are runtime configurable.

> I'm not familiar with how slub works, but I assume there's some overhead
> or some reason not to just use order 0 for <= kmalloc-4096?  Or is it
> purely just trying to reduce cpu by calling alloc_pages less often?

Using higher order pages reduces the memory overhead for objects (that
after all need to be packed into an order N page), decreases the amount
of metadata that needs to be managed and decreases the use of the
slowpaths. That implies also a reduction in the locking overhead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
