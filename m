Date: Wed, 5 Sep 2001 16:00:28 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] /proc/meminfo (fwd)
In-Reply-To: <20010905214552.B32584@athlon.random>
Message-ID: <Pine.LNX.4.33.0109051559270.16684-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Sep 2001, Andrea Arcangeli wrote:

> I fixed such bug ages ago:
>
> 	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.10pre4aa1/00_meminfo-wraparound-2

Is it scheduled for merging?  Arjan mentioned that it may have broken some
apps (like top) and have been pulled earlier.  My vote is for letting them
break and get fixed on highmem machines, but other people might have
different opinions.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
