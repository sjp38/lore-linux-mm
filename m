Date: Tue, 15 Jul 2003 11:20:01 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: VM docs and where they are going
Message-ID: <Pine.LNX.4.53.0307141634090.24480@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I made a small number of typo corrections and expanded the introduction
chapter a small bit on the Linux VM docs on my site. The changes are small
enough that if anyone has already printed it out, don't bother printing it
again. They are still available from the usual places.

Main document
PDF:  http://www.csn.ul.ie/~mel/projects/vm/guide/pdf/understand.pdf
HTML: http://www.csn.ul.ie/~mel/projects/vm/guide/html/understand/
Text: http://www.csn.ul.ie/~mel/projects/vm/guide/text/understand.txt

Code commentary
PDF:  http://www.csn.ul.ie/~mel/projects/vm/guide/pdf/code.pdf
HTML: http://www.csn.ul.ie/~mel/projects/vm/guide/html/code/
Text: http://www.csn.ul.ie/~mel/projects/vm/guide/text/code.txt

On the where it's going front from here, I'm happy to say I've now writing
a book which will be published under the Bruce Peren's Open Book Series
(http://www.perens.com/Books/). Some stuff that I'm working on for it
include;

o Better integration of the code commentary so it's easier to follow
o Much better introduction sections and updating of the software tools
o Shiny CD that comes with softcopy versions of the docs, browsable
  version of the tree and hopefully online call graph generation
o Chapter on anonymous shared memory including the virtual filesystem
o Assorted expansions and additions
o And best of all, a fairly detailed introduction to 2.6. The 2.6 sections
  are at the end of each chapter and give a fairly detailed account
  (right now, it's totalling about 30 pages) of what is new in 2.6 and
  how it is implemented

If all goes well, it'll be available before the end of this year or in
early 2004 :-)

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
