Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m8OMLSXe507848
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 22:21:28 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8OMLN0g4034566
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 00:21:27 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8OMLN1t018117
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 00:21:23 +0200
Subject: Re: PTE access rules & abstraction
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0809241919520.575@blonde.site>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
	 <1222117551.12085.39.camel@pasglop>
	 <Pine.LNX.4.64.0809241919520.575@blonde.site>
Content-Type: text/plain
Date: Thu, 25 Sep 2008 00:17:00 +0200
Message-Id: <1222294620.5968.4.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-24 at 19:45 +0100, Hugh Dickins wrote:
> > I know s390 has different issues & constraints. Martin told me during
> > Plumbers that mprotect was probably also broken for him.
> 
> Then I hope he will probably send Linus the fix.
> 
> Though what we already have falls somewhat short of perfection,
> I've much more enthusiasm for fixing its bugs, than for any fancy
> redesign introducing its own bugs.  Others have more stamina!

As far as I can tell the current code should work. It is not pretty
though, in particular the nasty pairing of flush_tlb_mm() with
ptep_set_wrprotect() and flush_tlb_range() with change_protection() is
fragile. For me the question is if we can find a sensible set of basic
primitives that work for all architectures in a performant way. This is
really hard..

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
