Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97C226B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 09:40:43 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/3] Reduce GFP_ATOMIC allocation failures, partial fix V3
Date: Tue, 27 Oct 2009 13:40:30 +0000
Message-Id: <1256650833-15516-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Since 2.6.31-rc1, there have been an increasing number of GFP_ATOMIC
failures. A significant number of these have been high-order GFP_ATOMIC
failures and while they are generally brushed away, there has been a large
increase in them recently and there are a number of possible areas the
problem could be in - core vm, page writeback and a specific driver. The
bugs affected by this that I am aware of are;

[Bug #14141] order 2 page allocation failures in iwlagn
[Bug #14141] order 2 page allocation failures (generic)
[Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
[No BZ ID]   Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
[No BZ ID]   page allocation failure message kernel 2.6.31.4 (tty-related)

The three patches in this series partially address the problem. I am
proposing these for merging to mainline and -stable now to reduce the number
of duplicate bug reports. The following bug should be fixed by these patches.

[No BZ ID] page allocation failure message kernel 2.6.31.4 (tty-related)

The following bug becomes very difficult to reproduce with these patches;

[Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100

The rest of the bugs remain open.

If these patches are agreed upon, they should be also considered -stable
candidates. Patch 1 does not apply cleanly but I can supply a version
that does.

 mm/page_alloc.c |    4 ++--
 mm/vmscan.c     |    9 +++++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
