Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1085377091.15281.49.camel@gaston>
References: <1085369393.15315.28.camel@gaston>
	 <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
	 <1085371988.15281.38.camel@gaston>
	 <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
	 <1085373839.14969.42.camel@gaston>
	 <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
	 <1085376888.24948.45.camel@gaston>  <1085377091.15281.49.camel@gaston>
Content-Type: text/plain
Message-Id: <1085377936.15024.55.camel@gaston>
Mime-Version: 1.0
Date: Mon, 24 May 2004 15:52:17 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2004-05-24 at 15:38, Benjamin Herrenschmidt wrote:
> > Well, the original scenario triggering that from userland is, imho, so
> > broken, that we may just not care losing that dirty bit ... Oh well :)
> > Anyway, apply my patch. If pte is not present, this will have no effect,
> > if it is, it makes sure we never leave a stale HPTE in the hash, which
> > is fatal in far worse ways.
> 
> Hrm... Or maybe I should just do in set_pte something like
> 
>  BUG_ON(pte_present(ptep))
> 
> That would make me sleep better ;)

 ... And would not work in the case you mentioned where we set it with
the dirty bit set... for write protect, we have a separate function now,
though. But I'm a bit paranoid with those PTE manipulations, so I think
it would be better to play it the safe way and keep my original patch.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
