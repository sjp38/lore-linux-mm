Date: Wed, 16 Jul 2003 10:55:52 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.0-test1-mm1
In-Reply-To: <6uwueidhdd.fsf@zork.zork.net>
Message-ID: <Pine.LNX.4.44.0307161052310.6193-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sean Neakums <sneakums@zork.net>
Cc: Andrew Morton <akpm@osdl.org>, Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jul 2003, Sean Neakums wrote:

> [...] If I keep running 'ps aux' its output does start to become slow
> again, snapping back to full speed after a few more runs.  Kind of an
> odd one.

there was a similar bug in the gnome terminal code, it was a userspace X
window-refresh/event-qeueing bug/race that was sensitive to scheduler
timings. So it can go away and come back based on precise timings. Eg. it
was more likely to happen with antialiasing turned on than off.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
