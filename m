Date: Sun, 24 Sep 2000 11:57:48 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: refill_inactive()
Message-ID: <Pine.LNX.4.21.0009241148100.2789-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

i'm wondering about the following piece of code in refill_inactive():

                if (current->need_resched && (gfp_mask & __GFP_IO)) {
                        __set_current_state(TASK_RUNNING);
                        schedule();
                }

shouldnt this be __GFP_WAIT? It's true that __GFP_IO implies __GFP_WAIT
(because IO cannot be done without potentially scheduling), so the code is
not buggy, but the above 'yielding' of the CPU should be done in the
GFP_BUFFER case as well. (which is __GFP_WAIT but not __GFP_IO)

Objections?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
