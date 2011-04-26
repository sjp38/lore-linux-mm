Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF179000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:51:07 -0400 (EDT)
Subject: Re: [PATCH 00/13] Swap-over-NBD without deadlocking
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110426144635.GK4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	 <1303827785.20212.266.camel@twins>  <20110426144635.GK4658@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 26 Apr 2011 16:50:49 +0200
Message-ID: <1303829449.20212.285.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>

On Tue, 2011-04-26 at 15:46 +0100, Mel Gorman wrote:
>=20
> I did find that only a few route-cache entries should be required. In
> the original patches I worked with, there was a reservation for the
> maximum possible number of route-cache entries. I thought this was
> overkill and instead reserved 1-per-active-swapfile-backed-by-NFS.

Right, so the thing I was worried about was a route-cache poison attack
where someone would spam the machine such that it would create a lot of
route cache entries and might flush the one we needed just as we needed
it.

Pinning the one entry we need would solve that (if possible).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
