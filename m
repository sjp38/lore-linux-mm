Subject: Re: rmap15a swappy?
References: <6uu1hjruye.fsf@zork.zork.net>
	<Pine.LNX.4.50L.0212121913030.17748-100000@imladris.surriel.com>
From: Sean Neakums <sneakums@zork.net>
Date: Thu, 12 Dec 2002 21:21:51 +0000
In-Reply-To: <Pine.LNX.4.50L.0212121913030.17748-100000@imladris.surriel.com> (Rik
 van Riel's message of "Thu, 12 Dec 2002 19:14:15 -0200 (BRST)")
Message-ID: <6uisxzrl00.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

commence  Rik van Riel quotation:

> On Thu, 12 Dec 2002, Sean Neakums wrote:
>
> Indeed, the older rmaps swapped later.  However, swapping
> a little bit earlier turns out to be faster for almost all
> workloads.

Oh right, because if you get sudden memory pressure you have a bunch
of pages that you can just throw away without writeout?

Anyway, that's nifty.  I just wanted to make sure it wasn't a
regression.

-- 
 /                          |
[|] Sean Neakums            |  Questions are a burden to others;
[|] <sneakums@zork.net>     |      answers a prison for oneself.
 \                          |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
