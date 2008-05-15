Date: Thu, 15 May 2008 10:33:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <20080515075747.GA7177@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805151031250.18708@schroedinger.engr.sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random>
 <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
 <20080508003838.GA9878@sgi.com> <200805132206.47655.nickpiggin@yahoo.com.au>
 <20080513153238.GL19717@sgi.com> <20080514041122.GE24516@wotan.suse.de>
 <20080514112625.GY9878@sgi.com> <20080515075747.GA7177@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 May 2008, Nick Piggin wrote:

> Oh, I get that confused because of the mixed up naming conventions
> there: unmap_page_range should actually be called zap_page_range. But
> at any rate, yes we can easily zap pagetables without holding mmap_sem.

How is that synchronized with code that walks the same pagetable. These 
walks may not hold mmap_sem either. I would expect that one could only 
remove a portion of the pagetable where we have some sort of guarantee 
that no accesses occur. So the removal of the vma prior ensures that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
