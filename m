Message-ID: <38043651.FA0BA70E@colorfullife.com>
Date: Wed, 13 Oct 1999 09:35:45 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [more fun] Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910120716490.22333-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> Another one: ptrace_readdata() -> access_process_vm() -> find_extend_vma()
> -> make_pages_present(). Again, no mmap_sem in sight.

Can 2 processes ptrace() each other? If yes, then this will lock-up if
you acquire the mmap_sem.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
