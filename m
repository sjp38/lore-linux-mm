Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C37438D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:21:27 -0500 (EST)
Date: Mon, 15 Nov 2010 15:21:22 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH/RFC 0/8] numa - Migrate-on-Fault
Message-ID: <20101115142122.GK7269@basil.fritz.box>
References: <20101111194450.12535.12611.sendpatchset@zaphod.localdomain>
 <20101114152440.E02E.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1011150809030.19175@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011150809030.19175@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Adding linux-mm where this should have been in the first place]

On Mon, Nov 15, 2010 at 08:13:14AM -0600, Christoph Lameter wrote:
> On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> 
> > Nice!
> 
> Lets not get overenthused. There has been no conclusive proof that the
> overhead introduced by automatic migration schemes is consistently less
> than the benefit obtained by moving the data. Quite to the contrary. We
> have over a decades worth of research and attempts on this issue and there
> was no general improvement to be had that way.

I agree it's not a good idea to enable this by default because
the cost of doing it wrong is too severe. But I suspect
it's a good idea to have optionally available for various workloads.

Good candidates so far:

- Virtualization with KVM (I think it's very promising for  that)
Basically this allows to keep guests local on nodes with their
own NUMA policy without having to statically bind them.

- Some HPC workloads. There were various older reports that 
it helped there.

So basically I think automatic migration would be good to have as
another option to enable in numactl.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
