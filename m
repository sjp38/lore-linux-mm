Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B91E8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 15:05:10 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Reduce the amount of time compaction disables IRQs for V2
Date: Fri, 25 Feb 2011 20:04:57 +0000
Message-Id: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Changelog since V1
  o Fix initialisation of isolated (Andrea)

The following two patches are aimed at reducing the amount of time IRQs are
disabled. It was reported by some ALSA people that transparent hugepages was
causing slowdowns on MIDI playback but I strongly suspect that compaction
running for smaller orders was also a factor. The theory was that IRQs
were being disabled for too long and sure enough, compaction was found to
be disabling IRQs for a long time. The patches reduce the length of time
IRQs are disabled when scanning for free pages and for pages to migrate.

It's late in the cycle but the IRQs disabled times are sufficiently bad
that it would be desirable to have these merged for 2.6.38 if possible.

 mm/compaction.c |   35 ++++++++++++++++++++++++++++++-----
 1 files changed, 30 insertions(+), 5 deletions(-)

-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
