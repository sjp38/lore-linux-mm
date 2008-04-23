Date: Wed, 23 Apr 2008 11:46:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
In-Reply-To: <20080423183718.GL24536@duo.random>
Message-ID: <Pine.LNX.4.64.0804231144460.13118@schroedinger.engr.sgi.com>
References: <ea87c15371b1bd49380c.1208872277@duo.random>
 <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com>
 <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com>
 <20080423133619.GV24536@duo.random> <20080423144747.GU30298@sgi.com>
 <20080423155940.GY24536@duo.random> <Pine.LNX.4.64.0804231105090.12373@schroedinger.engr.sgi.com>
 <20080423181928.GI24536@duo.random> <Pine.LNX.4.64.0804231122410.12373@schroedinger.engr.sgi.com>
 <20080423183718.GL24536@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008, Andrea Arcangeli wrote:

> Yes, there's really no risk of races in this area after introducing
> mm_lock, any place that mangles over ptes and doesn't hold any of the
> three locks is buggy anyway. I appreciate the audit work (I also did
> it and couldn't find bugs but the more eyes the better).

I guess I would need to merge some patches together somehow to be able 
to review them properly like I did before <sigh>. I have not reviewed the 
latest code completely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
