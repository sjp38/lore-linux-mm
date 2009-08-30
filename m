Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80B646B005A
	for <linux-mm@kvack.org>; Sun, 30 Aug 2009 08:58:25 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1517859bwz.38
        for <linux-mm@kvack.org>; Sun, 30 Aug 2009 05:58:33 -0700 (PDT)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: ipw2200: firmware DMA loading rework
Date: Sun, 30 Aug 2009 14:37:42 +0200
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <20090826074409.606b5124.akpm@linux-foundation.org> <1251430951.3704.181.camel@debian>
In-Reply-To: <1251430951.3704.181.camel@debian>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200908301437.42133.bzolnier@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Zhu Yi <yi.zhu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Friday 28 August 2009 05:42:31 Zhu Yi wrote:
> Bartlomiej Zolnierkiewicz reported an atomic order-6 allocation failure
> for ipw2200 firmware loading in kernel 2.6.30. High order allocation is

s/2.6.30/2.6.31-rc6/

The issue has always been there but it was some recent change that
explicitly triggered the allocation failures (after 2.6.31-rc1).

> likely to fail and should always be avoided.
> 
> The patch fixes this problem by replacing the original order-6
> pci_alloc_consistent() with an array of order-1 pages from a pci pool.
> This utilized the ipw2200 DMA command blocks (up to 64 slots). The
> maximum firmware size support remains the same (64*8K).
> 
> This patch fixes bug http://bugzilla.kernel.org/show_bug.cgi?id=14016
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

Thanks for the fix (also kudos to other people helping with the bugreport),
it works fine so far and looks OK to me:

Tested-and-reviewed-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
