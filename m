Subject: Re: 2.4 / 2.5 VM plans
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Rik van Riel's message of "Sun, 25 Jun 2000 00:51:42 -0300 (BRST)"
Date: 28 Jun 2000 23:17:57 +0200
Message-ID: <yttitutwlmi.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "rik" == Rik van Riel <riel@conectiva.com.br> writes:

Hi

rik> 2.4:

6) Integrate the shm code in the page cache, to evict having Yet
   another Cache to balance.

2.5:

7) Make a ->flush method in the address_space operations, Rik
   mentioned it in some previous mail, it should return the number of
   pages that it has flushed.  That would make shrink_mmap code (or
   its successor) more readable, as we don't have to add new code each
   time that we add a new type of page to the page cache.

8) This one is related with the FS, not MM specific, but FS people
   want to be able to allocate MultiPage buffers (see pagebuf from
   XFS) and people want similar functionality for other things.
   Perhaps we need to find some solution/who to do that in a clean
   way.  For instance, if the FS told us that he wants a buffer of 4
   pages, it is quite obvious how to do write clustering for a page in
   that buffer, we can use that information.

9) We need also to implement write clustering for fs/page cache/swap.
   Just now we have _not_ limit in the amount of IO that we start,
   that means that if we have all the memory full of dirty pages, we
   can have a _big_ stall while we wait for all the pages to be
   written to disk, and yes that happens with the actual code.


Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
