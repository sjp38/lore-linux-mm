Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4A41A6B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 22:02:07 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Thu, 15 Oct 2009 04:02:00 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091014165051.GE5027@csn.ul.ie> <1255552911.21134.51.camel@rc-desk>
In-Reply-To: <1255552911.21134.51.camel@rc-desk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910150402.03953.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: reinette chatre <reinette.chatre@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 14 October 2009, reinette chatre wrote:
> We do queue the GFP_KERNEL allocations when there are only a few buffers
> remaining in the queue (8 right now) ... maybe we can make this higher?

I've tried increasing it to 50. Here's the result for a single test:
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 25 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 48 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 48 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 48 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
__ratelimit: 1 callbacks suppressed
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
__ratelimit: 97 callbacks suppressed
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 44 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.

This is with current mainline (v2.6.32-rc4-149-ga3ccf63).

The log file timestamps don't tell much as the logging gets delayed,
so they all end up at the same time. Maybe I should enable the kernel
timestamps so we can see how far apart these failures are.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
