Date: Fri, 26 May 2000 22:25:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [bagpatch] VM sneak preview
Message-ID: <Pine.LNX.4.21.0005262219400.16128-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

as Roger Larson pointed out, one detail from my "new VM
sneak preview" patch doesn't make much sense. It does
not affect stability <hint> the patch has been running
smoothly for a number of people, you may want to try it</hint>.

You can fix it by editing mm/filemap.c and changing the
following code fragment (around line 270):

+               if (PageTestandClearReferenced(page)) {
+                       page->age += 3;
+                       if (page->age > 10)
+                               page->age = 0;
                                           ^^ should be 10
+                       goto dispose_continue;
+               }

Here the code checks if page->age exceeds the maximum. Of
course page->age should be set to the maximum value if it
does, and not all the way down to 0 :)

If you checked the patch and wondered why performance wasn't
always good ... this is it, things should just work now...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
