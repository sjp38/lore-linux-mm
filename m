Date: Wed, 31 Jan 2001 01:05:02 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] vma limited swapin readahead 
Message-ID: <Pine.LNX.4.21.0101310037540.16187-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

The current swapin readahead code reads a number of pages (1 >>
page_cluster)  which are physically contiguous on disk with reference to
the page which needs to be faulted in.

However, the pages which are contiguous on swap are not necessarily
contiguous in the virtual memory area where the fault happened. That means
the swapin readahead code may read pages which are not related to the
process which suffered a page fault.

I've changed the swapin code to not readahead pages if they are not
virtually contiguous on the vma which is being faulted to avoid
the problem described above.

Testers are very welcome since I'm unable to test this in various
workloads.

The patch is available at
http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.1pre10/swapin_readahead.patch


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
