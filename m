Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D40386B0072
	for <linux-mm@kvack.org>; Sat, 27 Oct 2012 17:20:58 -0400 (EDT)
Received: from unknown (HELO cesarb-inspiron.home.cesarb.net) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 27 Oct 2012 21:20:55 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 0/2] mm: do not call frontswap_init() during swapoff
Date: Sat, 27 Oct 2012 19:20:45 -0200
Message-Id: <1351372847-13625-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Cesar Eduardo Barros <cesarb@cesarb.net>

The call to frontswap_init() was added in a place where it is called not
only from sys_swapon, but also from sys_swapoff. This pair of patches
fixes that.

The first patch moves the acquisition of swap_lock from enable_swap_info
to two separate helpers, one for sys_swapon and one for sys_swapoff. As
a bonus, it also makes the code for sys_swapoff less subtle.

The second patch moves the call to frontswap_init() from the common code
to the helper used only by sys_swapon.

Compile-tested only, but should be safe.

Cesar Eduardo Barros (2):
  mm: refactor reinsert of swap_info in sys_swapoff
  mm: do not call frontswap_init() during swapoff

 mm/swapfile.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
