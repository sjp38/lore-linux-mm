Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 80A956B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 18:15:51 -0400 (EDT)
Date: Tue, 28 Sep 2010 23:15:46 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: cleanup gfp_zone()
Message-ID: <20100928221546.GI19804@ZenIV.linux.org.uk>
References: <1285676624-1300-1-git-send-email-namhyung@gmail.com>
 <20100928143239.5fe34e1e.akpm@linux-foundation.org>
 <20100928214141.GG19804@ZenIV.linux.org.uk>
 <20100928144518.0eaf1099.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100928144518.0eaf1099.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 02:45:18PM -0700, Andrew Morton wrote:
> On Tue, 28 Sep 2010 22:41:42 +0100
> > > hm.  I hope these sparse warnings are sufficiently useful to justify
> > > all the gunk we're adding to support them.
> > > 
> > > Is it actually finding any bugs?
> > 
> > FWIW, bitwise or done in the right-hand argumet of shift looks ugly as hell;
> > what the hell is that code _doing_?
> 
> There's a nice fat comment a few lines up...

[snip]

Egads...  IMO the cleanest way to deal with that is to add integer
constants, not to be used anywhere else (e.g. ___GFP_DMA, with
#define __GFP_DMA ((__force gfp_t)___GFP_DMA) and use them in that
horror.

As for the gfp_t warnings - yes, they'd caught a bunch of bugs at
some point; considering the bitrot rates... might be worth rechecking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
