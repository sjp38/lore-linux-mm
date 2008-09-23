Subject: Re: PTE access rules & abstraction
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <20080922.201610.246167553.davem@davemloft.net>
References: <48D739B2.1050202@goop.org> <1222117551.12085.39.camel@pasglop>
	 <20080923031037.GA11907@wotan.suse.de>
	 <20080922.201610.246167553.davem@davemloft.net>
Content-Type: text/plain
Date: Tue, 23 Sep 2008 15:35:06 +1000
Message-Id: <1222148106.12085.95.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: npiggin@suse.de, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-22 at 20:16 -0700, David Miller wrote:
> 
> To a certain extent this is what BSD does in it's pmap layer, except
> that they don't have the page table datastructure abstraction like
> Linus does in the generic code, and which I think was a smart design
> decision on our side.
> 
> All of the pmap modules in BSD are pretty big and duplicate a lot of
> code that arch's don't have to be mindful about under Linux.

I definitely agree, I don't think we want to go away from the page table
as being the abstraction :-) But I'm wondering if we can do a little bit
better with the accessors to those page tables.

BTW. am I the only one to have got one copy of David's reply (that I'm
quoting) coming with a From: Nick Piggin in the headers ? (apparently
coming from kvack).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
