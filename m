Subject: Re: PTE access rules & abstraction
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <48DC106D.9010601@goop.org>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
	 <1222117551.12085.39.camel@pasglop>
	 <Pine.LNX.4.64.0809241919520.575@blonde.site>
	 <1222291248.8277.90.camel@pasglop>
	 <Pine.LNX.4.64.0809250049270.21674@blonde.site>
	 <1222304686.8277.136.camel@pasglop>  <48DBD532.80607@goop.org>
	 <1222379063.8277.202.camel@pasglop>  <48DC106D.9010601@goop.org>
Content-Type: text/plain
Date: Fri, 26 Sep 2008 09:02:17 +1000
Message-Id: <1222383737.8277.205.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-09-25 at 15:27 -0700, Jeremy Fitzhardinge wrote:
> Yeah, that would work too; that's pretty much how Xen implements it
> anyway.  The main advantage of the start/commit pair is that the
> resulting code was completely unchanged from the old code.  The mprotect
> sequence using ptep_modify_protection would end up reading the pte twice
> before writing it.

Not necessarily .. depends how you factor out the interface to it.

Anyway, not a big deal now. I'll do a patch to fix the hole on powerpc,
and if my brain clicks, over the next few weeks, I'll see if I can come
up with an overall nicer API covering all usages. In many case might
just be a matter of giving a saner name to existing calls and
documenting them properly tho :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
