Date: Tue, 9 Apr 2002 10:47:53 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH][RC] radix-tree pagecache for 2.5
Message-ID: <20020409104753.A490@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I think I have a first release candidate of the radix-tree pagecache for
the 2.5 tree.  This patch contains the following changes over the last version

 - improved OOM handling all over the place		(Andrew Morton)
 - minor fixes/cleanuos					(Andrew Morton, me)
 - switch mapping->page_lock to a r/w lock		(me)

The patch can be found at:

	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.5/2.5.8-pre2/linux-2.5.8-ratcache.patch.gz
	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.5/2.5.8-pre2/linux-2.5.8-ratcache.patch.bz2

In addition a BitKeeper tree is available at http://hkernel.bkbits.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
