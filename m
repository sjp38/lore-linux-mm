Date: Tue, 20 Jun 2006 15:35:55 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
Message-Id: <20060620153555.0bd61e7b.akpm@osdl.org>
In-Reply-To: <20060408134635.22479.79269.sendpatchset@linux.site>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: benh@kernel.crashing.org, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:
>
> I've finally ported the RCU radix tree over my radix tree direct-data patch
> (the latter patch has been in -mm for a while now).

Yes, radix-tree-direct-data.patch and radix-tree-small.patch are for-2.6.18.

> I've also done the last step required for submission, which was to make a
> small userspace RCU test harness, and wire up the rtth so that it can handle
> multiple threads to test the lockless capability. The RCU test harness uses
> an implementation somewhat like Paul's paper's quiescent state bitmask
> approach; with infrequent quiescent state updates, performance isn't bad.
> 
> This quickly flushed out several obscure bugs just when running on my dual
> G5. After fixing those, I racked up about 100 CPU hours of testing on
> SUSE's 64-way Altix without problem. Also passes the normal battery of
> single threaded rtth tests.
> 
> I'd like to hear views regarding merging these patches for 2.6.18. Initially
> the lockless code would not come into effect (good - one thing at a time)
> until tree_lock can start getting lifted in -mm and 2.6.19.

For 2.6.18 we obviously need to fix the tree_lock box-killer as #1
priority.  And whatever we do there needs to be backportable to 2.6.17. 
Depending upon Dave's testing results that'll be either covert-to-spinlock
or disable-rwlock-debugging-if-CONFIG_DEBUG_SPINLOCK.  Or something else. 
We'll see.

So given those complexities, and the lack of a _user_ of
radix-tree-rcu-lockless-readside.patch, it doesn't look like 2.6.18 stuff
at this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
