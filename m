Date: Wed, 7 May 2008 16:09:48 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <20080507225801.GK8276@duo.random>
Message-ID: <alpine.LFD.1.10.0805071604480.3024@woody.linux-foundation.org>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random>
 <alpine.LFD.1.10.0805071540300.3024@woody.linux-foundation.org> <20080507225801.GK8276@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Thu, 8 May 2008, Andrea Arcangeli wrote:
>
> mmu_notifier_register only runs when windows or linux or macosx
> boots. Who could ever care of the msec spent in mm_lock compared to
> the time it takes to linux to boot?

Andrea, you're *this* close to going to my list of people who it is not 
worth reading email from, and where it's better for everybody involved if 
I just teach my spam-filter about it.

That code was CRAP.

That code was crap whether it's used once, or whether it's used a million 
times. Stop making excuses for it just because it's not performance- 
critical.

So give it up already. I told you what the non-crap solution was. It's 
simpler, faster, and is about two lines of code compared to the crappy 
version (which was what - 200 lines of crap with a big comment on top of 
it just to explain the idiocy?).

So until you can understand the better solution, don't even bother 
emailing me, ok? Because the next email I get from you that shows the 
intelligence level of a gnat, I'll just give up and put you in a 
spam-filter.

Because my IQ goes down just from reading your mails. I can't afford to 
continue.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
