Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA20384
	for <linux-mm@kvack.org>; Fri, 13 Nov 1998 14:00:50 -0500
Date: Fri, 13 Nov 1998 15:12:36 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: May be stupid question ;-)
In-Reply-To: <364C2049.360B6131@varel.bg>
Message-ID: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Petko Manolov <petkan@varel.bg>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Nov 1998, Petko Manolov wrote:

> I'm wonder if its possible to have kernel code+data > 4M? 

Currently not, unless you compile in all sorts of useless
drivers (or you have a machine with 30+ different kinds of
extension cards)...

> So pg0 won't be enough. And we have to init pg1. AFAIK the kernel
> don't allocate more page tables for itself while in run. It sounds
> to me like troubles in the future. 

Most of the runtime tables are allocated after the memory
stuff has been taken care off. Then we have the infrastructure
to allocate as much memory as we want without problems.

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
