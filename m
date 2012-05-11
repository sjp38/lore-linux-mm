Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id F12928D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 17:18:43 -0400 (EDT)
Date: Fri, 11 May 2012 17:17:38 -0400 (EDT)
Message-Id: <20120511.171738.549587472496189783.davem@davemloft.net>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120511143218.GS11435@suse.de>
References: <1336657510-24378-11-git-send-email-mgorman@suse.de>
	<20120511.005740.210437168371869566.davem@davemloft.net>
	<20120511143218.GS11435@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Fri, 11 May 2012 15:32:18 +0100

> On Fri, May 11, 2012 at 12:57:40AM -0400, David Miller wrote:
>> Please change this to be a static branch.
> 
> Will do. I renamed memalloc_socks to sk_memalloc_socks, made it a int as
> atomics are unnecessary and I check it directly in a branch instead of a
> static inline. It should be relatively easy for the branch predictor.

No branch predictor can beat an unconditional branch :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
