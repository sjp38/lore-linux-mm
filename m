Date: Mon, 19 Mar 2007 09:22:22 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Message-ID: <20070319092222.GA1720@infradead.org>
References: <20070318233008.GA32597093@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070318233008.GA32597093@melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 10:30:08AM +1100, David Chinner wrote:
> 
> Generic page_mkwrite functionality.
> 
> Filesystems that make use of the VM ->page_mkwrite() callout will generally use
> the same core code to implement it. There are several tricky truncate-related
> issues that we need to deal with here as we cannot take the i_mutex as we
> normally would for these paths.  These issues are not documented anywhere yet
> so block_page_mkwrite() seems like the best place to start.

This will need some updates when ->fault replaces ->page_mkwrite.

Nich, what's the plan for merging ->fault?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
