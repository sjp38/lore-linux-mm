Date: Fri, 21 Jul 2000 17:19:31 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] test5-pre1 vmfix (rev 8)
In-Reply-To: <Pine.Linu.4.10.10007180806290.591-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0007211716580.22938-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Roger Larsson <roger.larsson@norran.net>, Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jul 2000, Mike Galbraith wrote:
> On Tue, 18 Jul 2000, Roger Larsson wrote:
> 
> > * I get 10% better throughput than 2.4.0-test4, YMMV
> 
> Seeing about the same improvement here.. lightly tested.

Part of the code looks bogus though.

Linus, would it be possible to have a rule in place
that nobody submits VM code unless they accompany it
with an explanation of _why_ their code is supposed
to work?

There seem to be too many "random tweaks" in the current
VM code where nobody has an explanation of why the code works and
what exactly it is supposed to do...

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
