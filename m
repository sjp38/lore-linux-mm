Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA26858
	for <linux-mm@kvack.org>; Thu, 27 Nov 1997 08:37:53 -0500
Date: Thu, 27 Nov 1997 14:07:00 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: pageable page tables
In-Reply-To: <Pine.LNX.3.95.971126091603.8295A-100000@gwyn.tux.org>
Message-ID: <Pine.LNX.3.91.971127140510.259D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joel Gallun <joel@tux.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Nov 1997, Joel Gallun wrote:

> Wouldn't it be better to charge this against their ulimit? I'd rather not
> have the overhead of pageable page tables on a machine with no untrusted
> shell users (which I suspect is the majority of linux systems).

Then we would also need per-user accounting...
All-in-all however it's a very good idea.

(linux-kernel guys, would this break compatibility/POSIX or
whatever thing)

Rik.

ps: f-ups to linux-mm only.
----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
