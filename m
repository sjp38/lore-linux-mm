Date: Fri, 10 Dec 1999 00:21:18 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <199912092054.MAA57205@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9912100018160.11167-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rik van Riel <riel@nl.linux.org>, jgarzik@mandrakesoft.com, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 1999, Kanoj Sarcar wrote:

> Well, at least in 2.3, kernel data (and page caches) are below 1G,
> which means there's a lot of memory possible out there with
> references only from user memory. Shm page references are 
> revokable too. [...]

we already kindof replace pages, see replace_with_highmem(). Reverse ptes
do help, but are not a necessity to get this. Neither reverse ptes, nor
any other method guarantees that a large amount of continuous RAM can be
allocated. Only boot-time allocation can be guaranteed.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
