Date: Thu, 12 Oct 2000 22:02:42 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
In-Reply-To: <200010130029.RAA18914@pizda.ninka.net>
Message-ID: <Pine.LNX.4.10.10010122202350.14174-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: davej@suse.de, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 12 Oct 2000, David S. Miller wrote:
> 
>    Any of the mm gurus give the patch below a quick once over ?  Is
>    this adequate, or is there more to this than the description
>    implies?
> 
> It might make more sense to just make rss an atomic_t.

Agreed.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
