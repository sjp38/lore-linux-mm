Date: Sat, 30 Jun 2007 11:44:08 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] fsblock
Message-ID: <20070630104408.GD24123@infradead.org>
References: <20070624014528.GA17609@wotan.suse.de> <467DE00A.9080700@garzik.org> <20070624034755.GA3292@wotan.suse.de> <20070624135126.GA10077@think.oraclecorp.com> <467F67A8.3030408@yahoo.com.au> <20070625122521.GA12446@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070625122521.GA12446@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Jeff Garzik <jeff@garzik.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 25, 2007 at 08:25:21AM -0400, Chris Mason wrote:
> > write_begin/write_end is a step in that direction (and it helps
> > OCFS and GFS quite a bit). I think there is also not much reason
> > for writepage sites to require the page to lock the page and clear
> > the dirty bit themselves (which has seems ugly to me).
> 
> If we keep the page mapping information with the page all the time (ie
> writepage doesn't have to call get_block ever), it may be possible to
> avoid sending down a locked page.  But, I don't know the delayed
> allocation internals well enough to say for sure if that is true.

The point of delayed allocations is that the mapping information doesn't
even exist until writepage for new allocations :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
