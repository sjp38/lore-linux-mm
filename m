Date: Fri, 21 Jan 2000 03:08:56 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <E12BSNF-0001JF-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0001210301470.4332-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@nl.linux.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Alan Cox wrote:

>> The bank gives us 32 pages of credit. We don't need to get the I/O on
>> them. We have a credit that we can use to optimze the I/O.
>
>32 pages, thats 87 ethernet packets. At 100Mbit thats a rather short period
>of time. I make it 1/60th of a second

Actually the 32 pages I was talking about aren't the freepages.min but the
SWAP_CUSTER_MAX.

Anyway I think to see the problem described by Rik and actually I think it
can be fixed by killing the useless polling of 1 second and replacing it
with an unconiditional pre-wakeup of kswapd when GFP touch the
freepages.high watermark. This will in turn should also help performances
and it will try to free the cache from inside kswapd before a process have
to free it itself.

I said "useless polling" exactly because of what you said, that is a
network allocation will eat the freepages.min pages in less than 1 second.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
