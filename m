Date: Tue, 21 Dec 2004 10:36:28 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
Message-ID: <20041221093628.GA6231@wotan.suse.de>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2004 at 07:56:36PM -0800, Linus Torvalds wrote:
> 
> 
> On Mon, 20 Dec 2004, Linus Torvalds wrote:
> > 
> > (It may be _possible_ to avoid the warnings by just making "pud_t" and
> > "pmd_t" be the same type for such architectures, and just allowing
> > _mixing_ of three-level and four-level accesses.  I have to say that I 
> > consider that pretty borderline programming practice though).
> 
> Actually, I notice that this is exactly what you did, sorry for not being 
> more careful about reading your defines.
> 
> Thinking some more about it, I don't much like the "mixing" of 3-level and
> 4-level things, but since the only downside is a lack of type-safety for
> the 4-level case (ie you can get it wrong without getting any warning),
> and since that type safety _does_ exist in the case where the four levels 
> are actually used, I think it's ok. 


Sorry, but I don't.

> 
> It would be bad if the architecture that supported 4level page tables was
> really rare and broken (so that mistakes would happen and not get noticed
> for a while), but I suspect x86-64 by now is probably the second- or
> third-most used architecture, so it's not like the lack of type safety on 
> other architectures where it doesn't matter would be a huge maintenance 
> problem.

Sorry, but I think that's a very bad approach. If the i386 users
don't get warnings I will need to spend a lot of time just patching
behind them. While x86-64 is getting more and more popular most
hacking still happens on i386.

Please use a type safe approach that causes warnings
and errors on i386 too. Otherwise it'll cause me much additional
work longer term. Having the small advantage of a perhaps
slightly easier migration for long term maintenance hazzle
is a bad tradeoff IMHO.

Also is the flag day really that bad? I already did near all the work
IMHO (with the help of some architecture maintainers, thanks guys!)
and the patches are really not *that* bad. Linus can you please
at least take a second look at them before going with the non
typesafe hack? 

Thanks,

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
