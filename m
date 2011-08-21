Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8603E6B0169
	for <linux-mm@kvack.org>; Sun, 21 Aug 2011 04:56:21 -0400 (EDT)
Date: Sun, 21 Aug 2011 09:56:14 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Host where KSM appears to save a negative amount of memory
Message-ID: <20110821085614.GA3957@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-mm@kvack.org

We're running KSM on kernel 2.6.39.2 with hosts running a number qemu-kvm
virtual machines, and it has consistently been saving us a useful amount of
RAM.

To monitor the effective amount of memory saved, I've been looking at the
difference between /sys/kernel/mm/ksm/pages_sharing and pages_shared. On a
typical 32GB host, this has been coming out as at least a hundred thousand
or so, which is presumably half to one gigabyte worth of 4k pages.

However, this morning we've spotted something odd - a host where
pages_sharing is smaller than pages_shared, giving a negative saving by the
above calculation:

  # cat /sys/kernel/mm/ksm/pages_sharing
  1099994
  # cat /sys/kernel/mm/ksm/pages_shared
  1761313

I think this means my interpretation of these values must be wrong, as I
presumably can't have more pages being shared than instances of their use!
Can anyone shed any light on what might be going on here for me? Am I
misinterpreting these values, or does this look like it might be an
accounting bug? (If the latter, what useful debug info can I extract from
the system to help identify it?)

Best wishes,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
