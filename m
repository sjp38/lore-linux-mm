Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Date: Fri, 13 Oct 2000 23:47:55 +0100 (BST)
In-Reply-To: <20001013141723.C29525@twiddle.net> from "Richard Henderson" at Oct 13, 2000 02:17:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13kDcJ-0001fX-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Henderson <rth@twiddle.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, Oct 13, 2000 at 12:45:47PM +0100, Alan Cox wrote:
> > Can we always be sure the rss will fit in an atomic_t - is it > 32bits on the
> > ultrsparc/alpha ?
> 
> It is not.

Then we need to use locking to protect the rss since on a big 64bit box
we can exceed 2^32 pages in theory and probably soon in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
