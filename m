Received: from ucla.edu (pool0038-max2.ucla-ca-us.dialup.earthlink.net [207.217.13.102])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id XAA05692
	for <linux-mm@kvack.org>; Fri, 14 Jul 2000 23:12:03 -0700 (PDT)
Message-ID: <396F9F0A.99DFC1A2@ucla.edu>
Date: Fri, 14 Jul 2000 16:15:22 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: test5-pre1 VM best its EVER been!
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi - I've been testing test5-pre1.  I have a UP PPro 166, and 64Mb RAM.

The last kernel that I tried was test3-p7, and it had some problems.  It
tended to swap when there was FREE (not cache) memory still available. 
Also, it never completely swapped out unused daemons, and tended to swap
out large running processes, like netscape.

test5-pre1 is wonderful.  I mean, both the stats from vmstat, free, and
xosview, and the interactive feel.  I can REALLY run both netscape and
quake and the same time!  The system rarely hits the disk - which is a
welcome change.  Things the you might hope to be in the cache,
apparently are...

The swapping really is incredible.  I have 20MB swapped out right now,
and only 5 of that is netscape.  Netscape doesn't even swap in, so the
pages that are out really need to be out!  In contrast, lots of daemons
(dictionary servers, translation servers, font servers) which take up a
lot of room, have RSS=4k, which I think is the minimum.  This is really
superb.

Thanks, to those who did all the great work!  
Stil awaiting active/inactive lists and other stuff :)

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
