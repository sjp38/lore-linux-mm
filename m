Date: Mon, 30 Oct 2000 19:09:22 -0200
From: "Rodrigo S. de Castro" <rcastro@linux.ime.usp.br>
Subject: [RFC] Structure in Compressed Cache
Message-ID: <20001030190922.A5183@linux.ime.usp.br>
Reply-To: linux-mm@kvack.org, kernel@tutu.ime.usp.br
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

	In my implementation of compressed cache (kernel 2.2.16), I
started the project having my cache as a slab cache, structure
provided by kernel. I have all step 1 (a cache with no compression)
done, but I had a problem with marking pages in my cache. After an
email sent to the list about this subject, I started looking at shared
memory mechanism (mainly ipc/shm.c), and I saw that there's another
way of making it: with a page table allocation and memory mapping. I
could go on with my initial idea (with slab cache) but I think that
doing the latter way (with page table and memory mapping) would be
more complete (and, of course, harder). I will have a pool of
(compressed) pages that gotta be always in memory and will be
"between" physical memory and swap. As the project is growing I would
like to define now which path to follow, taking in account
completeness and upgradeability (to future versions of kernel). Which
way do you think that is better? Please, I also ask you to tell me in
case you know if there's another way, maybe better, of doing it.

Thank you in advance,
-- 
Rodrigo S. de Castro   <rcastro@linux.ime.usp.br>
University of Sao Paulo - Brazil
Compressed caching - http://tutu.ime.usp.br 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
