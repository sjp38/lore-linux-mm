Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060620163037.6ff2c8e7.akpm@osdl.org>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
	 <20060620153555.0bd61e7b.akpm@osdl.org>
	 <1150844989.1901.52.camel@localhost.localdomain>
	 <20060620163037.6ff2c8e7.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 21 Jun 2006 09:50:28 +1000
Message-Id: <1150847428.1901.60.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: npiggin@suse.de, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-20 at 16:30 -0700, Andrew Morton wrote:

> > leave the bug in ppc64 or kill it's scalability
> > when taking interrupts ? You have one user already, me.
> 
> I didn't know that 30 minutes ago ;)

Heh, I though I wrote that when I originally asked Nick to bring back
his patch up to date :) Bah, anyway, you know now. 

> > From what Nick
> > says, the patch has been beaten up pretty heavily and seems stable....
> 
> Well as I say, the tree_lock crash is way more important.  We need to work
> out what we're going to do then get that fixed, backport the fix to -stable
> then rebase the radix-tree patches on top and get
> radix-tree-rcu-lockless-readside.patch tested and reviewed.
> 
> I guess we can do all that in time for -rc1, but not knowing _how_ we'll be
> fixing the tree_lock crash is holding things up.

Ok.

> Paul, if you could take a close look at the RCU aspects of this work it'd
> help, thanks.
> 
> btw guys, theory has it that code which was submitted post-2.6.n is too
> late for 2.6.n+1..

Yes but the lockless radix tree patch was floating around a long time
ago :)

Anyway, I can drop a spinlock in (in fact I have) the ppc64 irq code for
now but that sucks, thus we should really seriously consider having the
lockless tree in 2.6.18 or I might have to look into doing an alternate
implementation specifically in arch code... or find some other way of
doing the inverse mapping there...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
