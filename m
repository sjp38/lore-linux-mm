Message-ID: <45FE61D3.90105@yahoo.com.au>
Date: Mon, 19 Mar 2007 21:11:31 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
References: <20070318233008.GA32597093@melbourne.sgi.com> <20070319092222.GA1720@infradead.org>
In-Reply-To: <20070319092222.GA1720@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Mon, Mar 19, 2007 at 10:30:08AM +1100, David Chinner wrote:
> 
>>Generic page_mkwrite functionality.
>>
>>Filesystems that make use of the VM ->page_mkwrite() callout will generally use
>>the same core code to implement it. There are several tricky truncate-related
>>issues that we need to deal with here as we cannot take the i_mutex as we
>>normally would for these paths.  These issues are not documented anywhere yet
>>so block_page_mkwrite() seems like the best place to start.
> 
> 
> This will need some updates when ->fault replaces ->page_mkwrite.
> 
> Nich, what's the plan for merging ->fault?

I've got the patches in -mm now. I hope they will get merged when the
the next window opens.

I didn't submit the ->page_mkwrite conversion yet, because I didn't
have any callers to look at. It is is slightly less trivial than for
nopage and nopfn, so having David's block_page_mkwrite is helpful.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
