Date: Mon, 22 Sep 2008 20:16:10 -0700 (PDT)
Message-Id: <20080922.201610.246167553.davem@davemloft.net>
Subject: Re: PTE access rules & abstraction
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080923031037.GA11907@wotan.suse.de>
References: <48D739B2.1050202@goop.org>
	<1222117551.12085.39.camel@pasglop>
	<20080923031037.GA11907@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Tue, 23 Sep 2008 05:10:37 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: benh@kernel.crashing.org, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

> Part of the problem with the pte API (as well as the cache flush and
> tlb flush APIs) is that it often involves the core mm code telling
> the arch how it thinks ptes,tlbs,caches should be managed, rather than
> I think the better approach would be telling the arch what it wants to
> do.
> 
> We are getting better slowly I think (eg. you note that set_pte_at is
> no longer used as a generic "do anything"), but I won't dispute that
> this whole area could use an overhaul; a document for all the rules,
> a single person or point of responsibility for those rules...

I agree.

To a certain extent this is what BSD does in it's pmap layer, except
that they don't have the page table datastructure abstraction like
Linus does in the generic code, and which I think was a smart design
decision on our side.

All of the pmap modules in BSD are pretty big and duplicate a lot of
code that arch's don't have to be mindful about under Linux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
