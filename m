Date: Thu, 30 Mar 2000 17:43:10 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003301639540.368-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0003301735420.593-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Mar 2000, Andrea Arcangeli wrote:

>[..] If something the higher is the priority the
>harder we should shrink the cache (that's the opposite that the patch
>achieves). Usually priority is always zero and the below check has no
>effect. [..]

thinko, I noticed I was wrong about this, apologies (prio start with 6 and
0 is the most severe one).

anyway I keep not enjoying such path for all the other reasons. It should
at _least_ be done outside the loop before calculating `count`.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
