Date: Tue, 18 Mar 2003 14:07:05 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: VM documentation
Message-ID: <Pine.LNX.4.53.0303181346500.11080@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Yet another release in the usual places. The main reasons for the release
is a correction on the subject of vmalloc more than anything else and the
rearrangement of chapters to present the material in more logical order. I
am hoping there will only be one, or at most two more releases after this
before it's done and dusted (famous last words).

Understanding the Linux Virtual Memory Manager
PDF:  http://www.csn.ul.ie/~mel/projects/vm/guide/pdf/understand.pdf
HTML: http://www.csn.ul.ie/~mel/projects/vm/guide/html/understand
Text: http://www.csn.ul.ie/~mel/projects/vm/guide/text/understand.txt

Code Commentary
PDF:  http://www.csn.ul.ie/~mel/projects/vm/guide/pdf/code.pdf
HTML: http://www.csn.ul.ie/~mel/projects/vm/guide/html/code
Text: http://www.csn.ul.ie/~mel/projects/vm/guide/text/code.txt

Few important reasons for this release but still, it brings me closer to
just finalising it and releasing it fully.

1. Chapters have been rearranged a little so there should be no forward
   references left and the material is handled in an "easier" order for
   understanding it. Each chapter now has an introduction as well so it
   isn't as clunky to read at parts

2. I messed up the explanation of vmalloc by saying pages are allocated at
   fault time rather than saying that it is just the page tables for the
   faulting process are synced with the master page tables. Pretty serious
   mistake so anyone looking at vmalloc stuff should re-read

3. Minor correction on the explanation of try_to_free_pages() in the code
   commentary. I now explain why it only frees up pages in ZONE_NORMAL

4. Loads of polish like font and grammar corrections. Minor mistake in
   slab where I said /proc/cpuinfo instead of /proc/slabinfo and a few
   others like that

-- 
Mel Gorman
MSc Student, University of Limerick
http://www.csn.ul.ie/~mel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
