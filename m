Message-ID: <20001110183823.A23474@saw.sw.com.sg>
Date: Fri, 10 Nov 2000 18:38:23 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Reserve VM for root (was: Re: Looking for better VM)
References: <Pine.LNX.4.05.10011081450320.3666-100000@humbolt.nl.linux.org> <Pine.LNX.4.21.0011091731100.1155-100000@fs129-190.f-secure.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0011091731100.1155-100000@fs129-190.f-secure.com>; from "Szabolcs Szakacsits" on Thu, Nov 09, 2000 at 06:30:32PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Nov 09, 2000 at 06:30:32PM +0100, Szabolcs Szakacsits wrote:
> BTW, I wanted to take a look at the frequently mentioned beancounter patch, 
> here is the current state,
> 	http://www.asp-linux.com/en/products/ubpatch.shtml 
> "Sorry, due to growing expenses for support of public version of ASPcomplete 
> we do not provide sources till first official release."

That's not a place where I keep my code (and has never been :-)

ftp://ftp.sw.com.sg/pub/Linux/people/saw/kernel/user_beancounter/UserBeancounter.html
is the right place (but it has some availability problems :-(

As for memory management, it provides a simple variant of service level
support for
 - in-core memory (in opposite to swap)
 - total "virtual" memory.
The latter ends up in accounting of how much memory is consumed by each
subject of accounting, and an OOM-killer.
OOM-killer takes into account guarantees given to the subject and selects the
victim.  In the patch on the ftp site the selection code is very simple and
taken from some old OOM patches.

BTW, I've redone memory accounting code to significantly improve it's
performance (or, to say in other words, to reduce the performance penalty
imposed by the accounting).  But this new code isn't integrated to the
complete user beancounter patch.

Best regards
		Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
