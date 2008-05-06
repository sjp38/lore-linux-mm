Date: Tue, 6 May 2008 22:22:01 +0200
From: Hans Rosenfeld <hans.rosenfeld@amd.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080506202201.GB12654@escobedo.amd.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com> <20080506124946.GA2146@elte.hu> <Pine.LNX.4.64.0805061435510.32567@blonde.site> <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062043580.11647@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805062043580.11647@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 08:49:23PM +0100, Hugh Dickins wrote:
> So Hans' original hugepage leak remains unexplained and unfixed.
> Hans, did you find that hugepage leak with a standard kernel, or were
> you perhaps trying out some hugepage-using patch of your own, without
> marking the vma VM_HUGETLB?  Or were you expecting the hugetlbfs file
> to truncate itself once all mmappers had gone?  If the standard kernel
> leaks hugepages, I'm surprised the hugetlb guys don't know about it.

I used a standard kernel (well, not quite, I had made some changes to
the /proc/pid/pagemap code, but nothing that would affect the hugepage
stuff) and some simple test program that would just mmap a hugepage.

I expected that any hugepage that a process had mmapped would
automatically be returned to the system when the process exits. That was
not the case, the process exited and the hugepage was lost (unless I
changed the program to explicitly munmap the hugepage before exiting).
Removing the hugetlbfs file containing the hugepage also didn't free the
page.


-- 
%SYSTEM-F-ANARCHISM, The operating system has been overthrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
