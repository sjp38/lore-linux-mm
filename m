Received: from mail2.isdnet.net (root@mail2.hol.fr [194.149.160.36])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18943
	for <linux-mm@kvack.org>; Thu, 20 Nov 1997 18:06:55 -0500
Date: Thu, 20 Nov 1997 23:54:03 +0100 (CET)
From: Mathieu Guillaume <mat@via.ecp.fr>
Subject: Re: [PATCH *] vhand-2.1.65b released
In-Reply-To: <Pine.LNX.3.91.971120105420.12363B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.971120234837.189A-100000@mat>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Thu, 20 Nov 1997, Rik van Riel wrote:
> since so many people have found something wrong with vhand-2.1.6[45]
> (particularly the CPU usage), I have implemented their ideas and
> I've made the 'anti-fragmentation' unit even more agressive, since
> some people still reported crashes because of memory fragmentation...

After my first tests (intensive use of tin+leafnode, which never failed to
freeze everything since 2.1.something), I can say I like the memory
management much better :)
SysReq reports 0 failed network buffer allocs, whereas I saw more than 20
millions without the patch.
I believe I saw some slowdowns sometimes, but I'm not sure if they're due
to vhand or if they would have happened anyway.
Anyway, I'm much happier with some slowdowns than with some complete
freezes.

Nice work !

					Mat
