Date: Fri, 19 Jul 2002 02:30:27 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: [PATCH 6/6] VM statistics for full rmap
Message-ID: <Pine.LNX.4.44.0207190154390.4647-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This adopts Rik van Riel's recent extended VM statistics patch for the 
'armed-to-the-gills-kitchen-sink rmap' against 2.5.26.  The aim, in 
combination with a meaningful benchmark suite, is to be able to have the 
statistical ammunition to fine tune the VM properly, rather than twiddling 
all knobs at once hoping to make things better. 

Get the patch series here: 
	http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.26/

Rik's original announcement is here:
	http://mail.nl.linux.org/linux-mm/2002-07/msg00172.html

and I have added Bill Irwin's alterations to the patch, described here:
	http://www.cs.helsinki.fi/linux/linux-kernel/2002-28/1287.html

Given the late hour, I have almost certainly forgotten some hooks in 
vmscan, so count it as a first, harmless cut at the problem.  Feedback 
and fixes welcome! :)

For 2.5.27, I'll make sure this patch is incremental to Rik's stats patch, 
and not a replacement for it.  Sorry 'bout that...

Craig Kulesa
Steward Observatory
Univ. of Arizona

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
