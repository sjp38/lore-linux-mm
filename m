Date: Fri, 13 Oct 2000 15:57:50 -0700
From: Richard Henderson <rth@twiddle.net>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Message-ID: <20001013155750.B29761@twiddle.net>
References: <20001013141723.C29525@twiddle.net> <E13kDcJ-0001fX-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E13kDcJ-0001fX-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 13, 2000 at 11:47:55PM +0100, Alan Cox wrote:
> Then we need to use locking to protect the rss since on a big 64bit box
> we can exceed 2^32 pages in theory and probably soon in practice.

Either that or adjust how we do atomic operations.  I can do
64-bit atomic widgetry, but not with the code as written.


r~
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
