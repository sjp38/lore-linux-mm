Date: Mon, 9 Oct 2000 20:28:44 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009202844.A19583@athlon.random>
References: <Pine.LNX.4.21.0010061555150.13585-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0010061611540.2191-100000@winds.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010061611540.2191-100000@winds.org>; from gandalf@winds.org on Fri, Oct 06, 2000 at 04:19:55PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Stanoszek <gandalf@winds.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 06, 2000 at 04:19:55PM -0400, Byron Stanoszek wrote:
> In the OOM killer, shouldn't there be a check for PID 1 just to enforce that

Init can't be killed in 2.2.x latest, the same bugfix should be forward
ported to 2.4.x.
 
> Can you give me your rationale for selecting 'nice' processes as being badder?

Also the cpu time and start time of a process are meaningless. Simulations
runs for weeks before they run the machine out of memory.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
