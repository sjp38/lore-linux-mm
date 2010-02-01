Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E4CA56B007D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 06:01:58 -0500 (EST)
Date: Mon, 1 Feb 2010 06:01:54 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100201110153.GA588@infradead.org>
References: <20081021082735.GB6974@wotan.suse.de> <20081021120932.GB13348@infradead.org> <20081022093018.GD4359@wotan.suse.de> <20100119121505.GA9428@infradead.org> <20100125075445.GD19664@laptop> <20100125081750.GA20012@infradead.org> <20100125083309.GF19664@laptop> <20100125123746.GA24406@laptop> <20100125213403.GA1309@infradead.org> <20100127083819.GA11072@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100127083819.GA11072@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 07:38:19PM +1100, Nick Piggin wrote:
> > So far I've not run out of vmalloc space yet with quite a few xfstests
> > iterations and not encountered any other problems either.
> > 
> > Thanks for looking into this!
> 
> OK thanks for testing. I'll send it upstream if you haven't had any
> problems so far.

Still working fine, so please send it upstream ASAP.  That'll make
re-eabling the scalable vmap API in XFS much more easier for 2.6.34.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
