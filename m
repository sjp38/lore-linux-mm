Subject: Re: pre8: where has the anti-hog code gone?
References: <Pine.LNX.4.10.10005130819330.1721-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Sat, 13 May 2000 08:28:40 -0700 (PDT)"
Date: 13 May 2000 20:14:26 +0200
Message-ID: <yttg0rm48sd.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

linus> So pre-8 with your suggested for for kswapd() looks pretty good, actually,
linus> but still has this issue that try_to_free_pages() seems to give up too
linus> easily and return failure when it shouldn't. I'll happily apply patches
linus> that make for nicer behaviour once this is clearly fixed, but not before
linus> (unless the "nicer behaviour" patch _also_ fixes the "pathological
linus> behaviour" case ;)

Here pre8, pre8 with any of the Rik patchs and pre9-1 looks bad.  If I
ran mmap002 in that machines it will be killed allways, now a lot of
times in around 30 seconds (in previous kernels the tests lasts around
3 min before being killed).  The system continues doing kills until
init dies, then all the system freezes, no net, no ping answer, no
keyboard answer (sysrq didn't work).  No information in logs, except
that some processes have been killed, no messages in the console
either.  If you need to reproduce the efect is easy, here in less than
5 min mmap002 test, the system is frozen.

If you need more information, let me know.

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
