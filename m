Date: Wed, 3 May 2000 17:42:14 -0700
Message-Id: <200005040042.RAA02046@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0005031813040.489-100000@alpha.random> (message
	from Andrea Arcangeli on Wed, 3 May 2000 18:26:19 +0200 (CEST))
Subject: Re: classzone-VM + mapped pages out of lru_cache
References: <Pine.LNX.4.21.0005031813040.489-100000@alpha.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, quintela@fi.udc.es
List-ID: <linux-mm.kvack.org>

	   ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.3/2.3.99-pre7-pre3/classzone-18.gz

Btw, the path seem to be incorrect.  It should be:

/pub/linux/kernel/people/andrea/patches/v2.3/2.3.99-pre7-pre3/classzone-18.gz

:-)

One note after initial study.  I wish we could get rid of the
"map_count" thing you added to the page struct.  Currently, when
we turn off wait queue debugging, the page struct is an exact power
of 2 on both 64-bit and 32-bit architectures.  With the map_count
there now, it will not be an exact power of two in size on 32-bit
machines :-(

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
