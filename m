Received: from caffeine.ix.net.nz (caffeine.ix.net.nz [203.97.118.28])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA28328
	for <linux-mm@kvack.org>; Wed, 19 May 1999 16:09:53 -0400
Date: Thu, 20 May 1999 08:09:44 +1200
From: Chris Wedgwood <chris@cybernet.co.nz>
Subject: Re: [VFS] move active filesystem
Message-ID: <19990520080944.A4173@caffeine.ix.net.nz>
References: <19990518183725.B30692@caffeine.ix.net.nz> <Pine.LNX.4.05.9905191820290.3829-100000@laser.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.05.9905191820290.3829-100000@laser.random>; from Andrea Arcangeli on Wed, May 19, 1999 at 06:28:04PM +0200
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@suse.de>
Cc: Gabor Lenart <lgb@oxygene.terra.vein.hu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Not really. We obviously can, but not in O(1).

Indeed... but not for arbitrary pages (eg. locked by other
susbsystems, drivers or applications)

> I could just add the logic to have the information in O(1), but
> then you must know that at every allocation you'll have to insert a
> entry in a queue, and remove an entry from a queue at every
> umapping/freeing of memory. Anyway I'll think I'll do that very
> soon to improve and simplify a lot my update_shared_mappings and
> many other similar thing in order to handle all such things in
> O(1).

Won't this be fairly expensive?





-cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
