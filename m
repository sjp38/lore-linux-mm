Received: from sunset.ma.huji.ac.il (sunset.ma.huji.ac.il [132.64.32.12])
	by kvack.org (8.8.7/8.8.7) with SMTP id DAA14768
	for <linux-mm@kvack.org>; Fri, 19 Dec 1997 03:32:09 -0500
Received: from ladybug.org.il (dial-12-2.slip.huji.ac.il [128.139.9.140]) by sunset.ma.huji.ac.il (8.6.11/8.6.10) with ESMTP id KAA17028 for <linux-mm@kvack.org>; Fri, 19 Dec 1997 10:27:21 +0200
Date: Thu, 18 Dec 1997 20:53:28 +0200 (IST)
From: Moshe Zadka <moshez@math.huji.ac.il>
Subject: Re: ideas for a swapping daemon
In-Reply-To: <Pine.LNX.3.95.971218112022.10225C-100000@as200.spellcast.com>
Message-ID: <Pine.LNX.3.96.971218205013.1610B-100000@ladybug.org.il>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Seems like a good idea. But experience with vhand
shows that what we should be most careful about is 
waking the swapping daemon too often, consuming 
resources. So, if anyone is writing it (I might
start by patching kswapd's routines to allow 
"forcing"), please keep an easily configurable
parameter (perhaps run-time adjusted through proc-fs)
controlling how often it is woken up, for easier
determining of the heuristics.

-- 
Moshe Zadka - moshez@math.huji.ac.il
Violating RFC2049 Should Be a Shooting Offense
