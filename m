From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free maps
Date: Mon, 27 Dec 2004 02:37:46 +0100
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org> <87llbk63sn.fsf@deneb.enyo.de>
In-Reply-To: <87llbk63sn.fsf@deneb.enyo.de>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200412270237.53368.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Florian Weimer <fw@deneb.enyo.de>, Linus Torvalds <torvalds@osdl.org>, 7eggert@gmx.de, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday 27 December 2004 00:24, Florian Weimer wrote:
> By the way, some crazy idea that occurred to me: What about
> incrementally scrubbing a page which has been assigned previously to
> this CPU, while spinning inside spinlocks (or busy-waiting somewhere
> else)?

Crazy idea, indeed. spinlocks are like safety belts: You should
actually not need them in the normal case, but they will save your butt
and you'll be glad you have them, when they actually trigger.

So if you are making serious progress here, you have just uncovered
a spinlockcontention problem in the kernel ;-)

Regards

Ingo Oeser

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBz2dvU56oYWuOrkARAvc+AJ0RpaIg6JzC28B8SOXE3irCBtaTVgCg1eas
5zACIzV2CtvlNvg6Bit+/G8=
=rdE7
-----END PGP SIGNATURE-----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
