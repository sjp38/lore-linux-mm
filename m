Message-ID: <41C80213.4050100@yahoo.com.au>
Date: Tue, 21 Dec 2004 21:59:31 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de>
In-Reply-To: <20041221093628.GA6231@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Mon, Dec 20, 2004 at 07:56:36PM -0800, Linus Torvalds wrote:

>>It would be bad if the architecture that supported 4level page tables was
>>really rare and broken (so that mistakes would happen and not get noticed
>>for a while), but I suspect x86-64 by now is probably the second- or
>>third-most used architecture, so it's not like the lack of type safety on 
>>other architectures where it doesn't matter would be a huge maintenance 
>>problem.
> 
> 
> Sorry, but I think that's a very bad approach. If the i386 users
> don't get warnings I will need to spend a lot of time just patching
> behind them. While x86-64 is getting more and more popular most
> hacking still happens on i386.
> 
> Please use a type safe approach that causes warnings
> and errors on i386 too. Otherwise it'll cause me much additional
> work longer term. Having the small advantage of a perhaps
> slightly easier migration for long term maintenance hazzle
> is a bad tradeoff IMHO.
> 

Oh yes, you're right there. And i386 will get warnings. The un-type-safe
headers are just for those architectures that haven't converted over yet.

I'm somewhat on the fence with this.

On one hand it does allow users, developers and arch maintainers of more
obscure architectures to have their kernels continue to work (provided that
I can get the thing working), and migrate over slowly.

But on the other hand, is it really needed? As you said, you've already
done much of the arch work in your patch...

Maybe it is a good thing in that it would allow my patchset to be picked
up _sooner_, which would encourage arch maintainers and speed progress.
With any luck, all traces of it would be gone before 2.6.11 is released.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
