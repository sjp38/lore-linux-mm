Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Date: Fri, 13 Oct 2000 12:45:47 +0100 (BST)
In-Reply-To: <200010130029.RAA18914@pizda.ninka.net> from "David S. Miller" at Oct 12, 2000 05:29:39 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13k3HY-0000yb-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>    Any of the mm gurus give the patch below a quick once over ?  Is
>    this adequate, or is there more to this than the description
>    implies?
> 
> It might make more sense to just make rss an atomic_t.

Can we always be sure the rss will fit in an atomic_t - is it > 32bits on the
ultrsparc/alpha ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
