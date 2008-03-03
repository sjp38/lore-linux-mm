Date: Mon, 3 Mar 2008 11:02:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v8
In-Reply-To: <20080303165910.GA23998@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0803031101260.6917@schroedinger.engr.sgi.com>
References: <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
 <20080303032934.GA3301@wotan.suse.de> <20080303125152.GS8091@v2.random>
 <20080303131017.GC13138@wotan.suse.de> <20080303151859.GA19374@sgi.com>
 <20080303165910.GA23998@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jack Steiner <steiner@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> It is going to be really easy to add more weird and wonderful notifiers
> later that deviate from our standard TLB model. It would be much harder to
> remove them. So I really want to see everyone conform to this model first.
> Numbers and comparisons can be brought out afterwards if people want to
> attempt to make such changes.

Still do not see how that could be done. The model here is tightly bound 
to ptes. AFAICT this could be implemented in arch code like the paravirt 
ops.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
