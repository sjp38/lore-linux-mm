Message-Id: <20070405174209.498059336@programming.kicks-ass.net>
Date: Thu, 05 Apr 2007 19:42:09 +0200
From: root@programming.kicks-ass.net
Subject: [PATCH 00/12] per device dirty throttling -v3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

Against 2.6.21-rc5-mm4 without:
  per-backing_dev-dirty-and-writeback-page-accounting.patch

This series implements BDI independent dirty limits and congestion control.

This should solve several problems we currently have in this area:

 - mutual interference starvation (for any number of BDIs), and
 - deadlocks with stacked BDIs (loop and FUSE).

All the fancy new congestion code has been compile and boot tested, but
not much more. I'm posting to get feedback on the ideas.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
