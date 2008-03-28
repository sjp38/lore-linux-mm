Date: Thu, 27 Mar 2008 21:09:10 -0700 (PDT)
Message-Id: <20080327.210910.101408473.davem@davemloft.net>
Subject: Re: [patch 1/2]: x86: implement pte_special
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080328040442.GE8083@wotan.suse.de>
References: <20080328033149.GD8083@wotan.suse.de>
	<20080327.204431.201380891.davem@davemloft.net>
	<20080328040442.GE8083@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Fri, 28 Mar 2008 05:04:42 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, shaggy@austin.ibm.com, axboe@oracle.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> BTW. if you are still interested, then the powerpc64 patch might be a
> better starting point for you. I don't know how the sparc tlb flush
> design looks like, but if it doesn't do a synchronous IPI to invalidate
> other threads, then you can't use the x86 approach.

I have soft bits available on sparc64, that's not my issue.

My issue is that if you implemented this differently, every platform
would get the optimization, without having to do anything special
at all, and I think that's such a much nicer way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
