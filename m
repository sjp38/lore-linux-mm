Date: Mon, 9 Oct 2000 23:38:18 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091825370.1562-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010092336230.9803-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Rik van Riel wrote:

> Would this complexity /really/ be worth it for the twice-yearly OOM
> situation?

the only reason i suggested this was the init=/bin/bash, 4MB RAM, no swap
emergency-bootup case. We must not kill init in that case - if the current
code doesnt then great and none of this is needed.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
