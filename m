Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA17287
	for <linux-mm@kvack.org>; Thu, 20 Nov 1997 12:09:16 -0500
Date: Thu, 20 Nov 1997 10:57:51 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH *] vhand-2.1.65b released
Message-ID: <Pine.LNX.3.91.971120105420.12363B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.rutgers.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi there,

since so many people have found something wrong with vhand-2.1.6[45]
(particularly the CPU usage), I have implemented their ideas and
I've made the 'anti-fragmentation' unit even more agressive, since
some people still reported crashes because of memory fragmentation...

You can get the patch at:
<a href="www.fys.ruu.nl/~riel/">my homepage</a>.

happy hacking,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
