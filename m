Date: Mon, 9 Oct 2000 17:18:12 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010092223100.8045-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0010091717160.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Ingo Molnar wrote:
> On Mon, 9 Oct 2000, Rik van Riel wrote:
> 
> > > so dns helper is killed first, then netscape. (my idea might not
> > > make sense though.)
> > 
> > It makes some sense, but I don't think OOM is something that
> > occurs often enough to care about it /that/ much...
> 
> i'm trying to handle Andrea's case, the init=/bin/bash
> manual-bootup case, with 4MB RAM and no swap, where the admin
> tries to exec a 2MB process. I think it's a legitimate concern -
> i cannot know in advance whether a freshly started process would
> trigger an OOM or not.

In that case the time running and the cpu time used
factors should give the new process a heavy penalty
compared to init.

(but I'd be curious if somebody actually manages to
trick the OOM killer into killing init ... please
test a bit more to see if this really happens ;))

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
