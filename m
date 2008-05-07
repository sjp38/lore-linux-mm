Date: Wed, 7 May 2008 16:03:00 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [ofa-general] Re: [PATCH 01 of 11] mmu-notifier-core
In-Reply-To: <20080507223914.GG8276@duo.random>
Message-ID: <alpine.LFD.1.10.0805071601090.3024@woody.linux-foundation.org>
References: <patchbomb.1210170950@duo.random> <e20917dcc8284b6a07cf.1210170951@duo.random> <20080507130528.adfd154c.akpm@linux-foundation.org> <alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org> <20080507215840.GB8276@duo.random>
 <alpine.LFD.1.10.0805071509270.3024@woody.linux-foundation.org> <20080507222758.GD8276@duo.random> <adaej8du4pf.fsf@cisco.com> <20080507223914.GG8276@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Roland Dreier <rdreier@cisco.com>, npiggin@suse.de, chrisw@redhat.com, rusty@rustcorp.com.au, a.p.zijlstra@chello.nl, marcelo@kvack.org, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, aliguori@us.ibm.com, paulmck@us.ibm.com, linux-mm@kvack.org, holt@sgi.com, general@lists.openfabrics.org, hugh@veritas.com, Andrew Morton <akpm@linux-foundation.org>, dada1@cosmosbay.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>


On Thu, 8 May 2008, Andrea Arcangeli wrote:
> 
> Ok so I see the problem Linus is referring to now (I received the hint
> by PM too), I thought the order of the signed-off-by was relevant, it
> clearly isn't or we're wasting space ;)

The order of the signed-offs are somewhat relevant, but no, sign-offs 
don't mean authorship.

See the rules for sign-off: you can sign off on another persons patches, 
even if they didn't sign off on them themselves. That's clause (b) in 
particular.

So yes, quite often you'd _expect_ the first sign-off to match the author, 
but that's a correlation, not a causal relationship.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
