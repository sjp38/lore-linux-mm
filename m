Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070307103842.GD5555@wotan.suse.de>
References: <20070307004709.432ddf97.akpm@linux-foundation.org>
	 <E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu>
	 <20070307010756.b31c8190.akpm@linux-foundation.org>
	 <1173259942.6374.125.camel@twins> <20070307094503.GD8609@wotan.suse.de>
	 <20070307100430.GA5080@wotan.suse.de> <1173262002.6374.128.camel@twins>
	 <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu>
	 <20070307102106.GB5555@wotan.suse.de> <1173263085.6374.132.camel@twins>
	 <20070307103842.GD5555@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 11:47:42 +0100
Message-Id: <1173264462.6374.140.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-07 at 11:38 +0100, Nick Piggin wrote:

> > > There are real users who want these fast, though.
> > 
> > Yeah, why don't we have a tree per nonlinear vma to find these pages?
> > 
> > wli mentions shadow page tables..
> 
> We could do something more efficient, but I thought that half the point
> was that they didn't carry any of this extra memory, and they could be
> really fast to set up at the expense of efficiency elsewhere.

I'm failing to understand this :-(

That extra memory, and apparently they don't want the inefficiency
either.

> I don't see it being a big deal. I doubt anybody is writing out huge
> amounts of data via nonlinear mappings.

Well, now they don't, but it could be done or even exploited as a DoS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
