Date: Wed, 15 Sep 2004 15:27:12 +0200
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
Message-ID: <20040915132712.GA6158@wohnheim.fh-wedel.de>
References: <413AA7B2.4000907@yahoo.com.au> <20040904230210.03fe3c11.davem@davemloft.net> <413AAF49.5070600@yahoo.com.au> <413AE6E7.5070103@yahoo.com.au> <Pine.LNX.4.58.0409051021290.2331@ppc970.osdl.org> <1094405830.2809.8.camel@laptop.fenrus.com> <Pine.LNX.4.58.0409051051120.2331@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.58.0409051051120.2331@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Arjan van de Ven <arjanv@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "David S. Miller" <davem@davemloft.net>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 September 2004 10:58:07 -0700, Linus Torvalds wrote:
> On Sun, 5 Sep 2004, Arjan van de Ven wrote:
> > 
> > well... we have a reverse mapping now. What is stopping us from doing
> > physical defragmentation ?
> 
> Nothing but replacement policy, really, and the fact that not everything
> is rmappable.

What about pointers?  I have an ethernet driver that hands pointers to
physical memory pages to hardware.  Would be fun if someone
defragmented those pages. ;)

Jorn

-- 
It's just what we asked for, but not what we want!
-- anonymous
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
