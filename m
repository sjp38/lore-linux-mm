Date: Fri, 13 Oct 2000 17:19:50 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Message-ID: <20001013171950.Y6207@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <200010130029.RAA18914@pizda.ninka.net> <E13k3HY-0000yb-00@the-village.bc.nu> <20001013141723.C29525@twiddle.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001013141723.C29525@twiddle.net>; from rth@twiddle.net on Fri, Oct 13, 2000 at 02:17:23PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Henderson <rth@twiddle.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 13, 2000 at 02:17:23PM -0700, Richard Henderson wrote:
> On Fri, Oct 13, 2000 at 12:45:47PM +0100, Alan Cox wrote:
> > Can we always be sure the rss will fit in an atomic_t - is it > 32bits on the
> > ultrsparc/alpha ?
> 
> It is not.

It is not even 32bit on sparc32 (24bit only).

	Jakub
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
