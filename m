Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 5F5D46B0083
	for <linux-mm@kvack.org>; Tue,  1 May 2012 18:28:30 -0400 (EDT)
Date: Tue, 1 May 2012 15:28:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/16] Swap-over-NBD without deadlocking V9
Message-Id: <20120501152826.b970a098.akpm@linux-foundation.org>
In-Reply-To: <1334578624-23257-1-git-send-email-mgorman@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>


This patchset is far less ghastly than I feared/remembered/dreamed ;)

The mm parts, anyway.  Are the net guys on board with it all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
