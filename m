Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6604F6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 16:30:40 -0400 (EDT)
Message-ID: <4DFBB94A.7030604@redhat.com>
Date: Fri, 17 Jun 2011 16:30:02 -0400
From: Josef Bacik <josef@redhat.com>
MIME-Version: 1.0
Subject: Some weirdness with slub in 3.0-rc*
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org
Cc: penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

Hello,

I started noticing that when I rmmod'ed btrfs after running a stress
test on it that it would complain about objects still left on a couple
of it's slab's.  I git bisect'ed it but it wasn't coming out right, and
I just ran the test again with slab instead of slub and it works out
fine.  Does this sound familiar to anyone?  I can try and bisect it
down, but the test takes like 30 minutes to reproduce (thankfully I can
reproduce this every time), so it's going to take a little bit if it
doesn't ring anybodies bells.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
