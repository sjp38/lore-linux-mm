Date: Fri, 13 Oct 2000 14:17:23 -0700
From: Richard Henderson <rth@twiddle.net>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Message-ID: <20001013141723.C29525@twiddle.net>
References: <200010130029.RAA18914@pizda.ninka.net> <E13k3HY-0000yb-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E13k3HY-0000yb-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 13, 2000 at 12:45:47PM +0100, Alan Cox wrote:
> Can we always be sure the rss will fit in an atomic_t - is it > 32bits on the
> ultrsparc/alpha ?

It is not.


r~
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
