Message-ID: <38039019.1D8A1531@colorfullife.com>
Date: Tue, 12 Oct 1999 21:46:33 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: vma_list_sem
References: <Pine.GSO.4.10.9910121353330.22333-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> b) correct code should not be punished. Ever. ASSERT is wrong.
> 

I'll remove the code from load_elf_binary() once I'm sure that the
down(mmap_sem) are really superflous. IIRC you agreed that
load_elf_library() needs the locking.
Possible problems for load_elf_binary():
* swap_out() could find that process. [seems safe]
* swap_out() could execute  "kill_proc(pid, SIGBUS, 1)" [not yet
checked]
* what about sys_ptrace()? [looks dangerous]

I really don't like the idea that a structure which can be found via
linked lists has no proper locking. Obviously, locking would be
superflous if noone has access to the "struct mm" pointer, but the
pointer can be eg. found by find_task_by_pid()->mm.


> Some of missing pieces (modulo binfmt-related stuff):
I'll add them, thanks,

	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
