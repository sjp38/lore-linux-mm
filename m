Message-ID: <45FF7259.8090004@yahoo.com.au>
Date: Tue, 20 Mar 2007 16:34:17 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
References: <20070318233008.GA32597093@melbourne.sgi.com> <20070319092222.GA1720@infradead.org> <45FE61D3.90105@yahoo.com.au> <20070319122252.GA12029@infradead.org>
In-Reply-To: <20070319122252.GA12029@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Mon, Mar 19, 2007 at 09:11:31PM +1100, Nick Piggin wrote:
> 
>>I've got the patches in -mm now. I hope they will get merged when the
>>the next window opens.
>>
>>I didn't submit the ->page_mkwrite conversion yet, because I didn't
>>have any callers to look at. It is is slightly less trivial than for
>>nopage and nopfn, so having David's block_page_mkwrite is helpful.
> 
> 
> Yes.  I was just wondering whether it makes more sense to do this
> functionality directly ontop of ->fault instead of converting i over
> real soon.

I would personally prefer that, but I don't want to block David's
patch from being merged if the ->fault patches do not get in next
cycle. If the fault patches do make it in first, then yes we should
do the page_mkwrite conversion before merging David's patch.

I'll keep an eye on it, and try to do the right thing.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
