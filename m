Date: Thu, 25 Sep 2008 00:55:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: PTE access rules & abstraction
In-Reply-To: <1222291248.8277.90.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0809250049270.21674@blonde.site>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
  <1222117551.12085.39.camel@pasglop>  <Pine.LNX.4.64.0809241919520.575@blonde.site>
 <1222291248.8277.90.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Sep 2008, Benjamin Herrenschmidt wrote:
> 
> Now, regarding the above bug, I'm afraid the only approaches I see that
> would work would be to have either a ptep_get_and_clear_flush(), which I
> suppose x86 virt. people will hate, or maybe to actually have a powerpc
> specific variant of the new start/commit hooks that does the flush.

Whyever not the latter?  Jeremy seems to have gifted that to you,
for precisely such a purpose.

Hugh

p.s. I surely agree with you over the name ptep_get_and_clear_full():
horrid, even more confusing than the tlb->fullmm from which it derives
its name.  I expect I'd agree with you over a lot more too, but please,
bugfixes first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
