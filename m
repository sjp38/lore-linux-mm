Date: Mon, 25 Jun 2007 10:58:26 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 1/3] add the fsblock layer
Message-ID: <20070625085826.GA19928@one.firstfloor.org>
References: <20070624014528.GA17609@wotan.suse.de> <20070624014613.GB17609@wotan.suse.de> <p73fy4h5q3c.fsf@bingen.suse.de> <1182716322.6819.3.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1182716322.6819.3.camel@laptopd505.fenrus.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 24, 2007 at 01:18:42PM -0700, Arjan van de Ven wrote:
> 
> > Hmm, could define a macro DECLARE_ATOMIC_BITMAP(maxbit) that expands to the smallest
> > possible type for each architecture. And a couple of ugly casts for set_bit et.al.
> > but those could be also hidden in macros. Should be relatively easy to do.
> 
> or make a "smallbit" type that is small/supported, so 64 bit if 32 bit
> isn't supported, otherwise 32

That wouldn't handle the case where you only need e.g. 8 bits
That's fine for x86 too. It only hates atomic accesses crossing cache line
boundaries (but handles them too, just slow) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
