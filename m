Date: Sat, 16 Jun 2007 20:41:30 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] madvise_need_mmap_write() usage
Message-ID: <20070616194130.GA6681@infradead.org>
References: <Pine.LNX.4.64.0706151118150.11498@dhcp83-20.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706151118150.11498@dhcp83-20.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Baron <jbaron@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 15, 2007 at 11:20:31AM -0400, Jason Baron wrote:
> hi,
> 
> i was just looking at the new madvise_need_mmap_write() call...can we
> avoid an extra case statement and function call as follows?

Sounds like a good idea, but please move the assignment out of the
conditional.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
