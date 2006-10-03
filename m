Message-ID: <20061003153103.xi28w00ww4w4o0co@www.email.arizona.edu>
Date: Tue,  3 Oct 2006 15:31:03 -0700
From: bithikak@email.arizona.edu
Subject: Fwd: vmtrace patch
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Marcelo,

A dry run of your vmtrace patch on my  2.6.17-1.2187_FC5 kernel gave the
following failures. I downloaded the patch from

http://hera.kernel.org/~marcelo/mm/vmtrace/vmtrace-0.0.tar.gz

Which kernel version did you write the patch for? It seems it is 2.6 but then
why does it fail for me?

Please advice.
Thanks
Bithika

************************** PATCH DRY RUN START *********************************
[root@dhcp-214 linux-2.6.17.x86_64]# patch -p1 <
vmtrace-0.0/kernel_patch/vmtrace-2.6-git-nov-2005.patch --dry-run
patching file include/asm-i386/pgtable.h
Hunk #2 FAILED at 225.
Hunk #3 FAILED at 238.
2 out of 3 hunks FAILED -- saving rejects to file include/asm-i386/pgtable.h.rej
patching file include/linux/vmtrace.h
patching file mm/Kconfig
patching file mm/Makefile
Hunk #1 FAILED at 20.
1 out of 1 hunk FAILED -- saving rejects to file mm/Makefile.rej
patching file mm/filemap.c
Hunk #1 succeeded at 552 (offset 47 lines).
patching file mm/memory.c
Hunk #1 succeeded at 433 with fuzz 1 (offset 67 lines).
Hunk #2 FAILED at 632.
Hunk #3 succeeded at 857 (offset 3 lines).
Hunk #4 succeeded at 2320 (offset 335 lines).
1 out of 4 hunks FAILED -- saving rejects to file mm/memory.c.rej
patching file mm/vmtrace.c
************************** PATCH DRY RUN END *********************************

----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
