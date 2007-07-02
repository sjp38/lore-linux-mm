Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l6275JZq252072
	for <linux-mm@kvack.org>; Mon, 2 Jul 2007 07:05:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6275JRu1601560
	for <linux-mm@kvack.org>; Mon, 2 Jul 2007 09:05:19 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6275IDY015824
	for <linux-mm@kvack.org>; Mon, 2 Jul 2007 09:05:19 +0200
Subject: Re: [patch 5/5] Optimize page_mkclean_one
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1183296468.5180.10.camel@lappy>
References: <20070629135530.912094590@de.ibm.com>
	 <20070629141528.511942868@de.ibm.com>
	 <Pine.LNX.4.64.0706301448450.13752@blonde.wat.veritas.com>
	 <1183274153.15924.6.camel@localhost>
	 <Pine.LNX.4.64.0707010926130.11148@blonde.wat.veritas.com>
	 <1183296468.5180.10.camel@lappy>
Content-Type: text/plain
Date: Mon, 02 Jul 2007 09:07:26 +0200
Message-Id: <1183360046.12198.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2007-07-01 at 15:27 +0200, Peter Zijlstra wrote:
> > But I could easily be overlooking something: Peter will recall.
> 
> /me tries to get his brain up to speed after the OLS closing party :-)

Oh-oh, the Black Thorn party :-)

> I did both pte_dirty and pte_write because I was extra careful. One
> _should_ imply the other, but since we'll be clearing both, I thought it
> prudent to also check both.

Just ran a little experiment: I've added a simple WARN_ON(ret == 0) to
page_mkclean after the page_test_dirty() check to see if there are cases
where the page is dirty and all ptes are read-only. A little stress run
including massive swap did not print a single warning.

> I will have to think on this a little more, but I'm currently of the
> opinion that the optimisation is not correct. But I'll have a thorough
> look at s390 again when I get home.

I think the patch is correct, although I beginning to doubt that is has
any effect.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
