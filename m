Date: Tue, 20 Jun 2006 16:30:37 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
Message-Id: <20060620163037.6ff2c8e7.akpm@osdl.org>
In-Reply-To: <1150844989.1901.52.camel@localhost.localdomain>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
	<20060620153555.0bd61e7b.akpm@osdl.org>
	<1150844989.1901.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: npiggin@suse.de, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> On Tue, 2006-06-20 at 15:35 -0700, Andrew Morton wrote:
> 
> > So given those complexities, and the lack of a _user_ of
> > radix-tree-rcu-lockless-readside.patch, it doesn't look like 2.6.18 stuff
> > at this time.
> 
> So what should I do ?

panic!

> leave the bug in ppc64 or kill it's scalability
> when taking interrupts ? You have one user already, me.

I didn't know that 30 minutes ago ;)

> From what Nick
> says, the patch has been beaten up pretty heavily and seems stable....

Well as I say, the tree_lock crash is way more important.  We need to work
out what we're going to do then get that fixed, backport the fix to -stable
then rebase the radix-tree patches on top and get
radix-tree-rcu-lockless-readside.patch tested and reviewed.

I guess we can do all that in time for -rc1, but not knowing _how_ we'll be
fixing the tree_lock crash is holding things up.

Paul, if you could take a close look at the RCU aspects of this work it'd
help, thanks.


btw guys, theory has it that code which was submitted post-2.6.n is too
late for 2.6.n+1..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
