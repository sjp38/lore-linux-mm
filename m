Date: Fri, 2 Feb 2007 08:21:33 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: half-fix page tail zeroing on write problem
Message-ID: <20070202072133.GA26431@wotan.suse.de>
References: <20070202055142.GA5004@wotan.suse.de> <17858.55858.642522.861130@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17858.55858.642522.861130@notabene.brown>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 02, 2007 at 05:29:06PM +1100, Neil Brown wrote:
> On Friday February 2, npiggin@suse.de wrote:
> > Hi,
> > 
> > For no important reason, I've again looked at those zeroing patches that
> > Neil did a while back. I've always thought that a simple
> > `write(fd, NULL, size)` would cause the same sorts of problems.
> 
> Yeh, but who in their right mind would do that???
> Oh, you did :-)

Well that's the test-case. Obviously not many people do it, but that's
all the more reason to be careful about correct behaviour.

> I cannot see why you make a change to fault_in_pages_writeable.  Is it
> just for symmetry?

Yes.

> For the rest, it certainly makes sense to return an early -EFAULT if
> you cannot fault in the page.

I think so.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
