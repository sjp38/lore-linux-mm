Date: Wed, 14 Jul 2004 22:41:38 +0900 (JST)
Message-Id: <20040714.224138.95803956.taka@valinux.co.jp>
Subject: [PATCH] memory hotremoval for linux-2.6.7 [0/16]
From: Hirokazu Takahashi <taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm pleased to say I've cleaned up the memory hotremoval patch
Mr. Iwamoto implemented. Part of ugly code has gone.

Main changes are:

  - Replaced the name remap with mmigrate as it was used for
    another fuctionality.

  - Made some of the memory hotremoval code share with the swapout-code.

  - Added many comments to describe the design of the memory hotremoval.

  - Added a basic funtion to support for memsection.
    try_to_migrate_page() is it. It continues to get a proper page
    in a specified section and migrate it while there remain pages
    in the section.

The patches are against linux-2.6.7.

Note that some patches are to fix bugs. Without the patches hugetlbpage
migration won't work.

Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
