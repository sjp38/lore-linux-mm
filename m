Date: Fri, 7 Mar 2008 12:15:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
 methods to sleep (#v9 was 1/4)
In-Reply-To: <20080307194728.GP24114@v2.random>
Message-ID: <Pine.LNX.4.64.0803071213370.6815@schroedinger.engr.sgi.com>
References: <20080304133020.GC5301@v2.random>
 <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
 <1204908762.8514.114.camel@twins> <20080307175019.GK24114@v2.random>
 <1204912895.8514.120.camel@twins> <20080307184552.GL24114@v2.random>
 <20080307194728.GP24114@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andrea Arcangeli wrote:

> This is a replacement for the previously posted 3/4, one of the pieces
> to allow the mmu notifier methods to sleep.

Looks good. That is what we talked about last week. What guarantees now 
that we see the cacheline referenced after the cacheline that 
contains the pointer that was changed? hlist_for_reach does a 
rcu_dereference with implied memory barrier? So its like EMM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
