Date: Mon, 27 Aug 2007 10:56:22 -0500
From: Dean Nelson <dcn@sgi.com>
Subject: [PATCH 0/4] SGI Altix cross partition memory (XPMEM)
Message-ID: <20070827155622.GA25589@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tony.luck@intel.com, akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jes@sgi.com
List-ID: <linux-mm.kvack.org>

    Terminology

The term 'partition', adopted by the SGI hardware designers and which
perculated up into the software, is used in reference to a single SSI
when multiple SSIs are running on a single Altix. An Altix running
multiple SSIs is said to be 'partitioned', whereas one that is running
only a single SSI is said to be 'unpartitioned'.

The term '[a]cross partition' refers to a functionality that spans between
two SSIs on a multi-SSI Altix. ('XP' is its abbreviation.)

    Introduction

This feature provides cross partition access to user memory (XPMEM) when
running multiple partitions on a single SGI Altix. XPMEM, like XPNET,
utilizes XPC to communicate between the partitions.

XPMEM allows a user process to identify portion(s) of its address space
that other user processes can attach (i.e. map) into their own address
spaces. These processes can be running on the same or a different
partition from the one whose memory they are attaching.

    Known Issues

XPMEM is not currently using the kthread API (which is also true for XPC)
because it was in the process of being changed to require a kthread_stop()
be done for every kthread_create() and the kthread_stop() couldn't be called
for a thread that had already exited. In talking with Eric Biederman, there
was some thought of creating a kthread_orphan() which would eliminate the
need for a call to kthread_stop() being required.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
