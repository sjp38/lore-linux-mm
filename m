Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep15-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050911203407.IUKZ24601.amsfep15-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 11 Sep 2005 22:34:07 +0200
Message-Id: <20050911202540.581022000@twins>
Date: Sun, 11 Sep 2005 22:25:40 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 0/7] CART Implementation v3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

Here my latest efforts on implementing CART, an advanced page replacement 
policy.

It seems pretty stable, except for a spurious OOM. However it yet has to
run on something other than UML.

A complete CART implementation should be present in cart-cart.patch. 
The cart-cart-r.patch improves thereon by keeping a 3th adaptive parameter
which measures the amount of fresh pages (not in |T1| u |T2| u |B1| u |B2|).
When the amount of fresh pages drops below the number of longterm pages
we start to reclaim pages that have just been inserted.

This works very well for a simple looped linear scan larger than the total 
resident set. Also it doesn't seem to regress normal workloads.

More test{s,ing} needed.

Kind regards,

Peter Zijlstra

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
