Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7AA6B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 18:21:48 -0400 (EDT)
Date: Mon, 8 Jun 2009 23:31:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Add a gfp-translate script to help understand page
	allocation failure reports
Message-ID: <20090608223135.GB18437@csn.ul.ie>
References: <20090608132950.GB15070@csn.ul.ie> <28c262360906080725o1e6d9e93t465ffeb53b093a17@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <28c262360906080725o1e6d9e93t465ffeb53b093a17@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 11:25:08PM +0900, Minchan Kim wrote:
> Hi, Mel.
> 
> How about handling it in kernel itself ?
> 

I posted a prototype patch that does something like that. It's not exactly
trivial to support without duplicating a pile of code or being very specific
to one use-case. I might have over-complicated things though.

> I mean we can print human-readable pretty format instead of
> non-understandable hex value. It can help us without knowing other's
> people's machine configuration.
> 

The downsides of handling this in kernel is that more strings are needed,
more code and it won't be of any use with reports from older kernels,
particularly distro kernels. There is scope for both having the script and
formatting it in-kernel.

> BTW, It would be better than now by your script.
> Thanks for sharing good tip. :)
> 

You're welcome.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
