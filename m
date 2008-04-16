Date: Wed, 16 Apr 2008 12:15:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
 operation to happen
In-Reply-To: <20080416190213.GK22493@sgi.com>
Message-ID: <Pine.LNX.4.64.0804161214170.14657@schroedinger.engr.sgi.com>
References: <patchbomb.1207669443@duo.random> <ec6d8f91b299cf26cce5.1207669444@duo.random>
 <20080416163337.GJ22493@sgi.com> <Pine.LNX.4.64.0804161134360.12296@schroedinger.engr.sgi.com>
 <20080416190213.GK22493@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008, Robin Holt wrote:

> On Wed, Apr 16, 2008 at 11:35:38AM -0700, Christoph Lameter wrote:
> > On Wed, 16 Apr 2008, Robin Holt wrote:
> > 
> > > I don't think this lock mechanism is completely working.  I have
> > > gotten a few failures trying to dereference 0x100100 which appears to
> > > be LIST_POISON1.
> > 
> > How does xpmem unregistering of notifiers work?
> 
> For the tests I have been running, we are waiting for the release
> callout as part of exit.

Some more details on the failure may be useful. AFAICT list_del[_rcu] is 
the culprit here and that is only used on release or unregister.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
