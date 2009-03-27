Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C1B0D6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 03:55:49 -0400 (EDT)
Date: Fri, 27 Mar 2009 01:05:27 -0700 (PDT)
Message-Id: <20090327.010527.201900502.davem@davemloft.net>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1238134235.20197.64.camel@pasglop>
References: <1238133267.20197.56.camel@pasglop>
	<20090326.225744.250374539.davem@davemloft.net>
	<1238134235.20197.64.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: benh@kernel.crashing.org
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 27 Mar 2009 17:10:35 +1100

[ zach@vmware.com removed from CC:, it bounces... ]

> So if you test current->mm, you effectively account for mm_users == 1,
> so the only way the mm can be active on another processor is as a lazy
> mm for a kernel thread. So your test should work properly as long
> as you don't have a HW that will do speculative TLB reloads into the
> TLB on that other CPU (and even if you do, you flush-on-switch-in should
> get rid of any crap here).

It seems that way.  I'll make this fix, thanks Ben!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
