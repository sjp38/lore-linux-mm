Date: Mon, 9 Oct 2000 14:44:37 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091839240.1562-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010091443020.1438-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 9 Oct 2000, Rik van Riel wrote:
>
> > I'd prefer just X having a higher "mm nice level" or something.
> 
> Which it has, because:
> 
> 1) CAP_RAW_IO
> 2) p->euid == 0

Oh, I agree, but we might want to generalize this a bit so that root could
say "this process is important" and then drop root privileges and still
get "credited" for the fact that it's important.

It's not a big deal. It works for X right now.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
