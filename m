From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910131834.LAA38192@google.engr.sgi.com>
Subject: Re: [more fun] Re: locking question: do_mmap(), do_munmap()
Date: Wed, 13 Oct 1999 11:34:32 -0700 (PDT)
In-Reply-To: <38043651.FA0BA70E@colorfullife.com> from "Manfred Spraul" at Oct 13, 99 09:35:45 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: viro@math.psu.edu, sct@redhat.com, andrea@suse.de, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Alexander Viro wrote:
> > Another one: ptrace_readdata() -> access_process_vm() -> find_extend_vma()
> > -> make_pages_present(). Again, no mmap_sem in sight.

Actually, I think access_process_vm() does get mmap_sem, although
after doing the find_extend_vma, which should be fixed. I will take
care of it in my patch.

> 
> Can 2 processes ptrace() each other? If yes, then this will lock-up if
> you acquire the mmap_sem.
>

Theoretically, there is no problem with 2 processes ptrace()ing each other.
IMO, no deadlock is possible in the approach I posted.

Kanoj

> --
> 	Manfred
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
