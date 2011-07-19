Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C26646B00EE
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 17:14:52 -0400 (EDT)
Date: Tue, 19 Jul 2011 17:14:38 -0400
From: Nick Bowler <nbowler@elliptictech.com>
Subject: kmemleak fails to report detected leaks after allocation failure
Message-ID: <20110719211438.GA21588@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Catalin Marinas <catalin.marinas@arm.com>

I just ran into a somewhat amusing issue with kmemleak.  After running
for a while (10 days), and detecting about 100 "suspected memory leaks",
kmemleak ultimately reported:

  kmemleak: Cannot allocate a kmemleak_object structure
  kmemleak: Automatic memory scanning thread ended
  kmemleak: Kernel memory leak detector disabled

OK, so something failed and kmemleak apparently can't recover from
this.  However, at this point, it appears that kmemleak has *also*
lost the ability to report the earlier leaks that it actually
detected.

  cat: /sys/kernel/debug/kmemleak: Device or resource busy

It seems to me that kmemleak shouldn't lose the ability to report leaks
that it already detected after it disables itself due to an issue that
was potentially caused by the very leaks that it managed to detect
(unlikely in this instance, but still...).

This was on a 2.6.39.2 kernel on x86_64.

I imagine that such a failure is unlikely to repeat itself, but I
figured I'd throw it out there.

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
