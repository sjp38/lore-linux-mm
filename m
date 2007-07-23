Date: Mon, 23 Jul 2007 12:36:18 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
Message-ID: <20070723123618.4a25f902@schroedinger.engr.sgi.com>
In-Reply-To: <20070714163319.GA14184@infradead.org>
References: <exportbomb.1184333503@pinky>
	<E1I9LJY-00006o-GK@hellhawk.shadowen.org>
	<20070714152058.GA12478@infradead.org>
	<Pine.LNX.4.64.0707140905140.31138@schroedinger.engr.sgi.com>
	<20070714163319.GA14184@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007 17:33:19 +0100
Christoph Hellwig <hch@infradead.org> wrote:
 
> It's not generic.  Most of it is under a maze of obscure config
> options. The patchset in it's current form is a complete mess of
> obscure ifefery and not quite generic code.  And it only adds new
> memory models without ripping old stuff out.  So while I really like
> the basic idea the patches need quite a lot more work until they're
> mergeable.

It is generic. If you would put the components into each arch then you
would needlessly duplicate code. In order to rip stuff out we first
need to have sparsemem contain all the features of discontig.

Then we can start to get rid of discontig and then we will be able to
reduce the number of memory models supported by sparsemem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
