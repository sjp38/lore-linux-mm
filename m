Message-ID: <392557B6.8C5EB817@ucla.edu>
Date: Fri, 19 May 2000 08:03:18 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: pre9-2+quintela = better, but still wrong pages swapped out
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi again, I have a UP system with 64MB RAM, and I'm not running pre9-2 +
Juan's patch.
	The feel is very nice and smooth - better than for example pre9-1. 
Also, doesn't have a problem than pre9-1 had, which is that it would
allow the page cache to get VERY small, when it should have swapped
pages out to preserve the page cache.  
	However, this kernel still swaps out the wrong pages.  It doesn't swap
very heavily, but it does swap out some pages from running tasks which
are later pages in.  pre7-4 did not have this problem.  It only paged
out pages from (say) unused daemons, if such pages were available. 
However, with this kernel, xfs-xtt sit in RAM taking up 2.5 Mb, and it
is never used.
	The kernel just never seems to get to xfstt, when scanning pages... It
and other daemons just sit there consuming memory.  Wierd.

-BenRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
