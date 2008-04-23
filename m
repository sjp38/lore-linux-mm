Date: Wed, 23 Apr 2008 11:21:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
In-Reply-To: <20080423172432.GE24536@duo.random>
Message-ID: <Pine.LNX.4.64.0804231120180.12373@schroedinger.engr.sgi.com>
References: <ea87c15371b1bd49380c.1208872277@duo.random>
 <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com>
 <20080422223545.GP24536@duo.random> <Pine.LNX.4.64.0804221619540.4996@schroedinger.engr.sgi.com>
 <20080423162629.GB24536@duo.random> <20080423172432.GE24536@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008, Andrea Arcangeli wrote:

> will go in -mm in time for 2.6.26. Let's put it this way, if I fail to
> merge mmu-notifier-core into 2.6.26 I'll voluntarily give up my entire
> patchset and leave maintainership to you so you move 1/N to N/N and
> remove mm_lock-sem patch (everything else can remain the same as it's
> all orthogonal so changing the order is a matter of minutes).

No I really want you to do this. I have no interest in a takeover in the 
future and have done the EMM stuff only because I saw no other way 
forward. I just want this be done the right way for all parties with 
patches that are nice and mergeable.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
