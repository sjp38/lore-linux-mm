Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
Date: Fri, 21 Jan 2000 00:56:24 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.21.0001210109141.3969-100000@alpha.random> from "Andrea Arcangeli" at Jan 21, 2000 01:42:28 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12BSNF-0001JF-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> The bank gives us 32 pages of credit. We don't need to get the I/O on
> them. We have a credit that we can use to optimze the I/O.

32 pages, thats 87 ethernet packets. At 100Mbit thats a rather short period
of time. I make it 1/60th of a second

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
