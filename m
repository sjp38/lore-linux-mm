Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id AF0026B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 01:04:51 -0400 (EDT)
Date: Fri, 11 May 2012 01:04:45 -0400 (EDT)
Message-Id: <20120511.010445.1020972261904383892.davem@davemloft.net>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V10
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net


Ok, I'm generally happy with the networking parts.

If you address my feedback I'll sign off on it.

The next question is whose tree this stuff goes through :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
