Date: Wed, 27 Sep 2000 15:56:08 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000927155608.D27898@athlon.random>
References: <20000925172442.J2615@redhat.com> <20000925190347.E27677@athlon.random> <20000925190657.N2615@redhat.com> <20000925213242.A30832@athlon.random> <20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com> <20000926160554.B13832@athlon.random> <qww7l7z86qo.fsf@sap.com> <20000926191027.A16692@athlon.random> <qwwn1gu6yps.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qwwn1gu6yps.fsf@sap.com>; from cr@sap.com on Wed, Sep 27, 2000 at 10:11:43AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 27, 2000 at 10:11:43AM +0200, Christoph Rohland wrote:
> I just checked one oracle system and it did not lock the memory. And I

If that memory is used for I/O cache then such memory should released when the
system runs into swap instead of swapping it out too (otherwise it's not cache
anymore and it could be slower than re-reading from disk the real data in
rawio).

> Customers with performance problems very often start with too little
> memory, but they cannot upgrade until this really big job finishes :-(
> 
> Another issue about shm swapping is interactive transactions, where
> some users have very large contexts and go for a coffee before
> submitting. This memory can be swapped. 

Agreed, that's why I said shm performance under swap is very important
as well (I'm not understimating it).

But again: if the shm contains I/O cache it should be released and not swapped
out.  Swapping out shmfs that contains I/O cache would be exactly like swapping
out page-cache.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
