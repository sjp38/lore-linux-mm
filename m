Date: Sat, 28 Aug 2004 17:08:23 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: refill_inactive_zone question
In-Reply-To: <20040827201641.GD3332@logos.cnet>
Message-ID: <Pine.LNX.4.44.0408281651270.2117-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Aug 2004, Marcelo Tosatti wrote:
> 
> Oh thanks! I see that. So you just dropped the bit spinlocked and changed
> mapcount to an atomic variable, right?

That's it, yes.  It needed a little more rework than that
(see ChangeLog) but that's the main thrust.

> Cool. Do you have any numbers on big SMP systems for that change? 

Sorry, no.  When I sent out the patches a second time to Andrew (didn't
copy LKML since nothing really changed from the first time in July),
I did CC Martin in the hope that he might feel the urge to run up
some numbers (or at least let him be aware of that change lest he
misinterpret numbers), but I think he was busy with other stuff.

All I had on it was the 10% off lmbench fork numbers on my 2*HT*P4.

> Talking about refill_inactive_zone(), the next stage of the algorithm:

Sorry, I'm going to have to leave you to sort this out with someone else
(I think Nick has replied), I'm not familiar with it, and I'm falling
way behind with the things I need to attend to.

> Hope I'm full of shit.

Yeah!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
