Date: Wed, 15 Sep 2004 16:18:19 +0200
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
Message-ID: <20040915141819.GC6158@wohnheim.fh-wedel.de>
References: <20040904230210.03fe3c11.davem@davemloft.net> <413AAF49.5070600@yahoo.com.au> <413AE6E7.5070103@yahoo.com.au> <Pine.LNX.4.58.0409051021290.2331@ppc970.osdl.org> <1094405830.2809.8.camel@laptop.fenrus.com> <Pine.LNX.4.58.0409051051120.2331@ppc970.osdl.org> <20040915132712.GA6158@wohnheim.fh-wedel.de> <20040915132904.GA30530@devserv.devel.redhat.com> <20040915133408.GB6158@wohnheim.fh-wedel.de> <20040915133939.GC30530@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20040915133939.GC30530@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, "David S. Miller" <davem@davemloft.net>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 September 2004 15:39:39 +0200, Arjan van de Ven wrote:
> 
> if your page is made unfreeable for the vm, for example by virtue of not
> being on the LRU or having an elevated count or.. or .. then such a page is
> pinned.
> 
> if your page is freeable byt he VM and your device is dmaing from/to it you
> have a really bad bug

Agreed.  skb->data should be safe as long as kfree_skb isn't called [1].
Thanks for the education.

[1] Actually, that does cause a really bad bug, but completely
unrelated to memory management.  kfree_skb does more than the name
indicates.  Patches will follow...

Jorn

-- 
Everything should be made as simple as possible, but not simpler.
-- Albert Einstein
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
