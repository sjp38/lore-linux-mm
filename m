Date: Wed, 29 Sep 2004 16:01:34 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: get_user_pages() still broken in 2.6
Message-ID: <20040929160134.A13683@infradead.org>
References: <4159E85A.6080806@ammasso.com> <20040929000325.A6758@infradead.org> <415ACB29.5000104@ammasso.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <415ACB29.5000104@ammasso.com>; from timur.tabi@ammasso.com on Wed, Sep 29, 2004 at 09:48:09AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <timur.tabi@ammasso.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 29, 2004 at 09:48:09AM -0500, Timur Tabi wrote:
> Christoph Hellwig wrote:
> 
> > get_user_pages locks the page in memory.  It doesn't do anything about ptes.
> 
> I don't understand the difference.  I thought a locked page is one that 
> stays in memory (i.e. isn't swapped out) and whose physical address 
> never changes.  Is that wrong?

Yes.  But if you're walking ptes you're looking at virtual addresses
somehow.  Can you send me a pointer to your code please?  I suspect
it's doing something terribly stupid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
