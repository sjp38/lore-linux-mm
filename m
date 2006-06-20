Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060620153555.0bd61e7b.akpm@osdl.org>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
	 <20060620153555.0bd61e7b.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 21 Jun 2006 09:09:49 +1000
Message-Id: <1150844989.1901.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-20 at 15:35 -0700, Andrew Morton wrote:

> So given those complexities, and the lack of a _user_ of
> radix-tree-rcu-lockless-readside.patch, it doesn't look like 2.6.18 stuff
> at this time.

So what should I do ? leave the bug in ppc64 or kill it's scalability
when taking interrupts ? You have one user already, me. From what Nick
says, the patch has been beaten up pretty heavily and seems stable....

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
