Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Date: Mon, 9 Oct 2000 22:10:36 +0100 (BST)
In-Reply-To: <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu> from "Ingo Molnar" at Oct 09, 2000 10:06:02 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13ikBx-0002qs-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> i think the OOM algorithm should not kill processes that have
> child-processes, it should first kill child-less 'leaves'. Killing a
> process that has child processes likely results in unexpected behavior of
> those child-processes. (and equals to effective killing of those
> child-processes as well.)

Lets kill a 6 week long typical background compute job because netscape exploded
(and yes netscape has a child process)

Rik's current OOM killer works very well but its a heuristic, so like all
heuristics you can always find a problem case

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
