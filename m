Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 961806B01B2
	for <linux-mm@kvack.org>; Sat, 22 May 2010 14:08:12 -0400 (EDT)
Received: from unknown (HELO delta.home.cesarb.net) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 22 May 2010 18:08:08 -0000
Message-ID: <4BF81D87.6010506@cesarb.net>
Date: Sat, 22 May 2010 15:08:07 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: [PATCH 0/3] mm: Swap checksum
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add support for checksumming the swap pages written to disk, using the
same checksum as btrfs (crc32c). Since the contents of the swap do not
matter after a shutdown, the checksum is kept in memory only.

Note that this code does not checksum the software suspend image.

Cesar Eduardo Barros (3):
       mm/swapfile.c: better messages for swap_info_get
       kernel/power/swap.c: do not use end_swap_bio_read
       mm: Swap checksum

  include/linux/swap.h |   31 +++++++-
  kernel/power/swap.c  |   21 +++++-
  mm/Kconfig           |   22 +++++
  mm/Makefile          |    1 +
  mm/page_io.c         |   92 ++++++++++++++++++--
  mm/swapcsum.c        |   94 +++++++++++++++++++++
  mm/swapfile.c        |  186 ++++++++++++++++++++++++++++++++++++++++--
  7 files changed, 429 insertions(+), 18 deletions(-)
  create mode 100644 mm/swapcsum.c

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
