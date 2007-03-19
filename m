Date: Mon, 19 Mar 2007 12:22:53 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Message-ID: <20070319122252.GA12029@infradead.org>
References: <20070318233008.GA32597093@melbourne.sgi.com> <20070319092222.GA1720@infradead.org> <45FE61D3.90105@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45FE61D3.90105@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 09:11:31PM +1100, Nick Piggin wrote:
> I've got the patches in -mm now. I hope they will get merged when the
> the next window opens.
> 
> I didn't submit the ->page_mkwrite conversion yet, because I didn't
> have any callers to look at. It is is slightly less trivial than for
> nopage and nopfn, so having David's block_page_mkwrite is helpful.

Yes.  I was just wondering whether it makes more sense to do this
functionality directly ontop of ->fault instead of converting i over
real soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
