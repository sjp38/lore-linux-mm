Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA28563
	for <linux-mm@kvack.org>; Sat, 26 Sep 1998 05:01:41 -0400
Date: Sat, 26 Sep 1998 09:36:04 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: error in OOM patch 2.1.122 ;(
Message-ID: <Pine.LNX.3.96.980926093337.17118B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: OOM patch list -- Claus Fischer <cfischer@td2cad.intel.com>, Linux MM <linux-mm@kvack.org>, Ragnar Hojland Espinosa <ragnar@lightside.ddns.org>, Samuli Kaski <samkaski@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Hi,

Ragnar just found a small error in the latest OOM patch...

The first sqrt( line in badness() should read:
points /= int_sqrt(int_sqrt((p->times.tms_utime + p->times.tms_stime)
>> (SHIFT_HZ + 3)));

sorry for the inconvenience...

grtz,

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
