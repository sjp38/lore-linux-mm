Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id E6A796B00F1
	for <linux-mm@kvack.org>; Thu,  3 May 2012 11:00:52 -0400 (EDT)
Date: Thu, 3 May 2012 16:00:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/16] Swap-over-NBD without deadlocking V9
Message-ID: <20120503150048.GI11435@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
 <20120501152826.b970a098.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120501152826.b970a098.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Tue, May 01, 2012 at 03:28:26PM -0700, Andrew Morton wrote:
> 
> This patchset is far less ghastly than I feared/remembered/dreamed ;)
> 

That might be the best comment the series ever received :)

> The mm parts, anyway.  Are the net guys on board with it all?

They are cc'd but have not given any feedback in a while. That could be
because they are happy with it or because if they felt the MM parts were
blocking the series then it was unnecessary to review the network parts.

Any of the networking people care to comment?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
