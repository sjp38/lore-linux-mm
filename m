Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k94Fs2iP018423
	for <linux-mm@kvack.org>; Wed, 4 Oct 2006 11:54:02 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k94Fs2UX224098
	for <linux-mm@kvack.org>; Wed, 4 Oct 2006 11:54:02 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k94Fs1q6006664
	for <linux-mm@kvack.org>; Wed, 4 Oct 2006 11:54:02 -0400
Subject: [ANNOUNCE] libhugetlbfs 1.0 released
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 04 Oct 2006 10:53:54 -0500
Message-Id: <1159977235.10255.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: libhugetlbfs-devel@lists.sourceforge.net
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, nacc@us.ibm.com, "Steven J. Fox [imap]" <drfickle@us.ibm.com>, David Gibson <david@gibson.dropbear.id.au>, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

libhugetlbfs-1.0 Released

After roughly one year in development, version 1.0 of libhugetlbfs is here.
It can be downloaded from SourceForge or the OzLabs mirror:

	http://sourceforge.net/project/showfiles.php?group_id=156936
	http://libhugetlbfs.ozlabs.org/snapshots/

=====================

What is libhugetlbfs?

In Linux, access to hugepages is provided through a virtual file
system, "hugetlbfs".  The libhugetlbfs library interface works with
hugetlbfs to provide more convenient specific application-level
services.  In particular libhugetlbfs has three main functions:

        * library functions
libhugetlbfs provides functions that allow an applications to
explicitly allocate and use hugepages more easily they could by
directly accessing the hugetblfs filesystem

        * hugepage malloc()
libhugetlbfs can be used to make an existing application use hugepages
for all its malloc() calls.  This works on an existing (dynamically
linked) application binary without modification.

        * hugepage text/data/BSS
libhugetlbfs, in conjunction with included special linker scripts can
be used to make an application which will store its executable text,
its initialized data or BSS, or all of the above in hugepages.  This
requires relinking an application, but does not require source-level
modifications.

This HOWTO explains how to use the libhugetlbfs library.  It is for
application developers or system administrators who wish to use any of
the above functions.

The libhugetlbfs library is a focal point to simplify and standardise
the use of the kernel API.

=====================


After a series of preview releases, we have tested a huge array of the
supported usage scenarios using benchmarks and real HPC applications.
Usability and reliability have greatly improved.  But... due to the
incredible diversity of applications that exist, there is bound to be a few
that will not work correctly.  

If using libhugetlbfs makes your application slower:

 * Play around with the different combinations of hugetlb malloc and the
   two different supported link types to see which combination works best.

 * Keep in mind that huge pages are a niche performance tweak and are not
   suitable for every type of application.  They are specifically known to
   hurt performance in certain situations.

If you experience problems:

 * You've already read the HOWTO document, but read through it again.  It
   is full of hints, notes, warnings, and caveats that we have found over
   time.  This is the best starting point for a quick resolution to your
   issue.

 * Make sure you have enough huge pages allocated.  Even if you think you
   have enough, try increasing it to a number you know you will not use.

 * Set HUGETLB_VERBOSE=99 and HUGETLB_DEBUG=yes.  These options increase
   the verbosity of the library and enable extra checking to help diagnose
   the problem.

If the above steps do not help, send as much information about the problem
(including all libhugetlbfs debug output) to
libhugetlbfs-devel@lists.sourceforge.net and we'll help out as much as we
can.  We will probably ask you to collect things like: straces,
/proc/pid/maps and gdb back traces.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
