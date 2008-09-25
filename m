Subject: Re: PTE access rules & abstraction
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <Pine.LNX.4.64.0809250049270.21674@blonde.site>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
	 <1222117551.12085.39.camel@pasglop>
	 <Pine.LNX.4.64.0809241919520.575@blonde.site>
	 <1222291248.8277.90.camel@pasglop>
	 <Pine.LNX.4.64.0809250049270.21674@blonde.site>
Content-Type: text/plain
Date: Thu, 25 Sep 2008 11:04:46 +1000
Message-Id: <1222304686.8277.136.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-09-25 at 00:55 +0100, Hugh Dickins wrote:
> 
> Whyever not the latter?  Jeremy seems to have gifted that to you,
> for precisely such a purpose.

Yeah. Not that I don't quite understand what the point of the
start/modify/commit thing the way it's currently used in mprotect since
we are doing the whole transaction for a single PTE change, ie how does
that help with hypervisors vs. a single ptep_modify_protection() for
example is beyond me :-)

When I think about transactions, I think about starting a transaction,
changing a -bunch- of PTEs, then commiting... Essentially I see the PTE
lock thing as being a transaction.

Cheers,
Ben.

> Hugh
> 
> p.s. I surely agree with you over the name ptep_get_and_clear_full():
> horrid, even more confusing than the tlb->fullmm from which it derives
> its name.  I expect I'd agree with you over a lot more too, but
> please, bugfixes first.

Sure.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
