In-reply-to: <20070308115843.GA22781@wotan.suse.de> (message from Nick Piggin
	on Thu, 8 Mar 2007 12:58:44 +0100)
Subject: Re: [RFC][PATCH] mm: fix page_mkclean() vs non-linear vmas
References: <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins> <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins> <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins> <1173278067.6374.188.camel@twins> <20070307150102.GH18704@wotan.suse.de> <1173286682.6374.191.camel@twins> <E1HPGg9-00039z-00@dorka.pomaz.szeredi.hu> <20070308115843.GA22781@wotan.suse.de>
Message-Id: <E1HPHRK-0003EV-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 08 Mar 2007 13:09:46 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, jdike@addtoit.com, hugh@veritas.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> >   - it's a maintenance burden: I'll have to layer the m/ctime update
> >     patch on top of this
> 
> But you have to update m/ctime for BDI_CAP_NO_WRITEBACK mappings anyway
> don't you?

Yes, but that's a different aspect of msync(), not about the data
writeback issues that nonlinear mappings have.

So a solution that solves both these problems would probably be more
complex.

> >   - the only pro for this has been that Nick thinks it cool ;)
> 
> Nonlinear in general, rather than this specifically.

Fair enough.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
