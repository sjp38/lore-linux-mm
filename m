Date: Wed, 7 Mar 2007 15:50:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307145042.GG18704@wotan.suse.de>
References: <20070307103842.GD5555@wotan.suse.de> <1173264462.6374.140.camel@twins> <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins> <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins> <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins> <20070307133649.GF18704@wotan.suse.de> <E1HOwZn-0000TI-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1HOwZn-0000TI-00@dorka.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 02:53:07PM +0100, Miklos Szeredi wrote:
> > > msync() might never get called and then we're back with the old
> > > behaviour where we can surprise the VM with a ton of dirty pages.
> > 
> > But we're root. With your patch, root *can't* do nonlinear writeback
> > well. Ever. With msync, at least you give them enough rope.
> 
> Restricting to root doesn't buy you much, nobody wants to be root.
> Restricting to mlock is similarly pointless.  UML _will_ want to get
> swapped out if there's no activity.

They could always not use nonlinear, or we could add a ulimit to the
size of nonlinear vaddr allowed. 

> Restricting to tmpfs makes sense, but it's probably not what UML
> wants.

I think it is OK. They might want some persistent storage to migrate
or something, but that can always be done by copying from tmpfs to
a block based filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
