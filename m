Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 18B5C6B009D
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 16:34:06 -0500 (EST)
Date: Mon, 25 Jan 2010 16:34:03 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100125213403.GA1309@infradead.org>
References: <20081021082542.GA6974@wotan.suse.de> <20081021082735.GB6974@wotan.suse.de> <20081021120932.GB13348@infradead.org> <20081022093018.GD4359@wotan.suse.de> <20100119121505.GA9428@infradead.org> <20100125075445.GD19664@laptop> <20100125081750.GA20012@infradead.org> <20100125083309.GF19664@laptop> <20100125123746.GA24406@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125123746.GA24406@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 11:37:46PM +1100, Nick Piggin wrote:
> On Mon, Jan 25, 2010 at 07:33:09PM +1100, Nick Piggin wrote:
> > > Any easy way to get them?  Sorry, not uptodate on your new vmalloc
> > > implementation anymore.
> > 
> > Let me try writing a few (tested) patches here first that I can send you.
> 
> Well is it easy to reproduce the vmap failure? Here is a better tested
> patch if you can try it. It fixes a couple of bugs and does some purging
> of fragmented blocks.

So far I've not run out of vmalloc space yet with quite a few xfstests
iterations and not encountered any other problems either.

Thanks for looking into this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
