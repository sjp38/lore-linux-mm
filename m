Date: Sun, 24 Mar 2002 12:34:14 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: [PATCH] updated radix-tree pagecache
Message-ID: <20020324123414.A12686@caldera.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: velco@fadata.bg
List-ID: <linux-mm.kvack.org>

I've just uploaded a new version of the radix-tree pagecache patch
to kernel.org.  This version should fix the OOPSens in the last 
version by beeing more carefull with the page->flags handling.

I have tested the 2.4 version under varying loads for about 20 hours
now and it seems stabel, the 2.5 version just got a compiles & boots,
I don't really trust 2.5 in this stage..

The only real difference between the two patches is the use of Ingo
Molnar's mempool interface in the 2.5 version, this is needed to not
deadlock under extreme loads.  If you want to have this with a 2.4-based
kernel you have to get a mempool backport from somewhere and just copy
lib/radix-tree.c from the 2.5 radix pagecache patch.

The patches are located at:

	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.4/2.4.19-pre4/linux-2.4.19-radixpagecache.patch.gz
	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.4/2.4.19-pre4/linux-2.4.19-radixpagecache.patch.bz2

	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.5/2.5.7/linux-2.5.7-radixpagecache.patch.gz
	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.5/2.5.7/linux-2.5.7-radixpagecache.patch.bz2

Please give them some beating so I can declare them ready for 2.5 when
Linus is back from vacation..

	Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
