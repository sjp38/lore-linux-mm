Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: broken VM in 2.4.10-pre9
Date: Thu, 20 Sep 2001 15:40:55 +0200
References: <E15k3O2-0005Fr-00@the-village.bc.nu>
In-Reply-To: <E15k3O2-0005Fr-00@the-village.bc.nu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010920133330Z16274-2757+894@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 20, 2001 02:57 pm, Alan Cox wrote:
> > On September 20, 2001 12:04 am, Alan Cox wrote:
> > > Reverse mappings make linear aging easier to do but are not critical (we
> > > can walk all physical pages via the page map array).
> >
> > But you can't pick up the referenced bit that way, so no up aging, only
> > down.
>
> #1 If you really wanted to you could update a referenced bit in the page
> struct in the fault handling path.

Right, we probably should do that.  But consider that any time this happens a
reverse map would have eliminated the fault because we wouldn't need to unmap
the page until we're actually going to free it.

> #2 If a page is referenced multiple times by different processes is the
> behaviour of multiple upward aging actually wrong.

With rmap it's easy to do it either way: either treat the ref bits as if
they're all or'd together or, perhaps more sensibly, age up by an amount that
depends on the number of ref bits set, but not as much as UP_AGE * refs.

--
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
