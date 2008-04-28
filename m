Date: Mon, 28 Apr 2008 13:34:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
In-Reply-To: <20080427122727.GO9514@duo.random>
Message-ID: <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com>
References: <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com>
 <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random>
 <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random>
 <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random>
 <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com>
 <20080427122727.GO9514@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Sun, 27 Apr 2008, Andrea Arcangeli wrote:

> Talking about post 2.6.26: the refcount with rcu in the anon-vma
> conversion seems unnecessary and may explain part of the AIM slowdown
> too. The rest looks ok and probably we should switch the code to a
> compile-time decision between rwlock and rwsem (so obsoleting the
> current spinlock).

You are going to take a semphore in an rcu section? Guess you did not 
activate all debugging options while testing? I was not aware that you can 
take a sleeping lock from a non preemptible context.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
