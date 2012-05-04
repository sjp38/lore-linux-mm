Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id CA4BE6B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 06:17:06 -0400 (EDT)
Date: Fri, 4 May 2012 11:16:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/16] Swap-over-NBD without deadlocking V9
Message-ID: <20120504101659.GK11435@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
 <20120501152826.b970a098.akpm@linux-foundation.org>
 <20120503150048.GI11435@suse.de>
 <20120503.130611.160512784868698446.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120503.130611.160512784868698446.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

On Thu, May 03, 2012 at 01:06:11PM -0400, David Miller wrote:
> From: Mel Gorman <mgorman@suse.de>
> Date: Thu, 3 May 2012 16:00:48 +0100
> 
> > Any of the networking people care to comment?
> 
> Post another series with any lingering feedback you've received and
> I'll make sure it gets queued up in patchwork so that it gets properly
> reviewed by us.
> 

Will do, thanks a lot. Tests are currently running on a rebased series
and I'll post after a successful completion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
