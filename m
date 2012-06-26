Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 46F8F6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 16:13:51 -0400 (EDT)
Date: Tue, 26 Jun 2012 22:13:28 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 11/16] netvm: Propagate page->pfmemalloc from
 skb_alloc_page to skb
Message-ID: <20120626201328.GI6509@breakpoint.cc>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-12-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340375443-22455-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Jun 22, 2012 at 03:30:38PM +0100, Mel Gorman wrote:
>  drivers/net/ethernet/chelsio/cxgb4/sge.c          |    2 +-
>  drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |    2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 +-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 +-
>  drivers/net/usb/cdc-phonet.c                      |    2 +-
>  drivers/usb/gadget/f_phonet.c                     |    2 +-

You did not touch all drivers which use alloc_page(s)() like e1000(e). Was
this on purpose?

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
