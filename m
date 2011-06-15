Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 046F76B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:13:55 -0400 (EDT)
Date: Wed, 15 Jun 2011 18:11:48 -0400 (EDT)
Message-Id: <20110615.181148.650483947691740732.davem@davemloft.net>
Subject: Re: [PATCH] slob: push the min alignment to long long
From: David Miller <davem@davemloft.net>
In-Reply-To: <1308171355.15617.401.camel@calx>
References: <1308169466.15617.378.camel@calx>
	<BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
	<1308171355.15617.401.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpm@selenic.com
Cc: penberg@kernel.org, sebastian@breakpoint.cc, cl@linux-foundation.org, linux-mm@kvack.org, netfilter@vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 15 Jun 2011 15:55:55 -0500

> In general, I think the right thing is to require every arch to
> explicitly document its alignment requirements via defines in the kernel
> headers so that random hackers don't have to scour the internet for
> datasheets on obscure architectures they don't care about.

Blink... because the compiler doesn't provide a portable way to
do this, right? :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
