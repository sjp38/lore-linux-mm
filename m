Date: Wed, 31 Oct 2007 12:18:00 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: NBD was Re: [PATCH 00/33] Swap over NFS -v14
Message-ID: <20071031111800.GA2551@elf.ucw.cz>
References: <20071030160401.296770000@chello.nl> <200710311426.33223.nickpiggin@yahoo.com.au> <20071030.213753.126064697.davem@davemloft.net> <20071031085041.GA4362@infradead.org> <1193828206.27652.145.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1193828206.27652.145.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi!

> > So please get the VM bits for swap over network blockdevices in first,
> 
> Trouble with that part is that we don't have any sane network block
> devices atm, NBD is utter crap, and iSCSI is too complex to be called
> sane.

Hey, NBD was designed to be _simple_. And I think it works okay in
that area.. so can you elaborate on "utter crap"? [Ok, performance is
not great.]

Plus, I'd suggest you to look at ata-over-ethernet. It is in tree
today, quite simple, but should have better performance than nbd.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
