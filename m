Date: Sun, 26 Dec 2004 21:33:05 -0700 (MST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free
 maps
In-Reply-To: <200412270237.53368.ioe-lkml@rameria.de>
Message-ID: <Pine.LNX.4.61.0412262131410.17702@montezuma.fsmlabs.com>
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
 <87llbk63sn.fsf@deneb.enyo.de> <200412270237.53368.ioe-lkml@rameria.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
Cc: linux-kernel@vger.kernel.org, Florian Weimer <fw@deneb.enyo.de>, Linus Torvalds <torvalds@osdl.org>, 7eggert@gmx.de, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Dec 2004, Ingo Oeser wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On Monday 27 December 2004 00:24, Florian Weimer wrote:
> > By the way, some crazy idea that occurred to me: What about
> > incrementally scrubbing a page which has been assigned previously to
> > this CPU, while spinning inside spinlocks (or busy-waiting somewhere
> > else)?
> 
> Crazy idea, indeed. spinlocks are like safety belts: You should
> actually not need them in the normal case, but they will save your butt
> and you'll be glad you have them, when they actually trigger.
> 
> So if you are making serious progress here, you have just uncovered
> a spinlockcontention problem in the kernel ;-)

You'd also be evicting the cache contents thus making the lock contention 
case even worse.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
