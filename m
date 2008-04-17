Date: Fri, 18 Apr 2008 00:16:55 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-ID: <20080417221655.GA9287@duo.random>
References: <patchbomb.1207669443@duo.random> <ec6d8f91b299cf26cce5.1207669444@duo.random> <20080416163337.GJ22493@sgi.com> <Pine.LNX.4.64.0804161134360.12296@schroedinger.engr.sgi.com> <20080417155157.GC17187@duo.random> <20080417163642.GE11364@sgi.com> <20080417171443.GM17187@duo.random> <Pine.LNX.4.64.0804171202420.23938@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804171202420.23938@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 12:10:52PM -0700, Christoph Lameter wrote:
> EMM was/is using a single linked list which allows atomic updates. Looked 
> cleaner to me since doubly linked list must update two pointers.

Cleaner would be if it would provide an abstraction in list.h. The
important is the memory taken by the head for this usage.

> I have not seen docs on the locking so not sure why you use rcu 
> operations here? Isnt the requirement to have either rmap locks or 
> mmap_sem held enough to guarantee the consistency of the doubly linked list?

Yes, exactly, I'm not using rcu anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
