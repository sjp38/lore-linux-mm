Date: Sat, 2 Sep 2000 18:39:22 +0100 (GMT)
From: John Levon <moz@compsoc.man.ac.uk>
Subject: Rik van Riel's VM patch
Message-ID: <Pine.LNX.4.21.0009021834220.21467-100000@mrbusy.compsoc.man.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, this is just a short no-statistics testimony that Rik's VM patch
to test8-pre1 seems much improved over test7. I have a UP P200 with 40Mb,
and previously running KDE2 + mozilla was totally unusable. 

With the patch, things run much more smoothly. Interactive feel seems
better, and I don't have "swapping holidays" any more.

Heavily stressing it by g++ is better as well... 

just a data point,
john

-- 
"It's a damn poor mind that can only think of one way to spell a word."
	- Andrew Jackson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
