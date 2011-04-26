Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 823C09000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:23:24 -0400 (EDT)
Subject: Re: [PATCH 00/13] Swap-over-NBD without deadlocking
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1303803414-5937-1-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 26 Apr 2011 16:23:05 +0200
Message-ID: <1303827785.20212.266.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>

On Tue, 2011-04-26 at 08:36 +0100, Mel Gorman wrote:
> Comments?

Last time I brought up the whole swap over network bits I was pointed
towards the generic skb recycling work:

  http://lwn.net/Articles/332037/

as a means to pre-allocate memory, and it was suggested to simply pin
the few route-cache entries required to route these packets and
dis-allow swap packets to be fragmented (these last two avoid lots of
funny allocation cases in the network stack).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
