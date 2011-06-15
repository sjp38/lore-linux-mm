Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA666B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:10:20 -0400 (EDT)
Date: Wed, 15 Jun 2011 18:08:06 -0400 (EDT)
Message-Id: <20110615.180806.768765303507703068.davem@davemloft.net>
Subject: Re: [PATCH] slob: push the min alignment to long long
From: David Miller <davem@davemloft.net>
In-Reply-To: <20110615201202.GB19593@Chamillionaire.breakpoint.cc>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
	<1308089140.15617.221.camel@calx>
	<20110615201202.GB19593@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sebastian@breakpoint.cc
Cc: mpm@selenic.com, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, netfilter@vger.kernel.org

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Wed, 15 Jun 2011 22:12:02 +0200

> I doubt that 4 was the correct answer. On x86_32 you still get 4.

No in certain circumstances with current gcc versions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
