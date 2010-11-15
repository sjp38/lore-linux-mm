Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AEC0E8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:38:55 -0500 (EST)
Date: Mon, 15 Nov 2010 15:37:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH/RFC 0/8] numa - Migrate-on-Fault
Message-ID: <20101115143747.GD6809@random.random>
References: <20101111194450.12535.12611.sendpatchset@zaphod.localdomain>
 <20101114152440.E02E.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1011150809030.19175@router.home>
 <20101115142122.GK7269@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101115142122.GK7269@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Avi Kivity <avi@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 03:21:22PM +0100, Andi Kleen wrote:
> - Virtualization with KVM (I think it's very promising for  that)
> Basically this allows to keep guests local on nodes with their
> own NUMA policy without having to statically bind them.

Confirm, KVM virtualization needs automatic migration (we need the cpu
to follow memory in a smart way too), hard bindings are not ok, like
hugetlbfs is not ok as VM are moved across nodes, swapped, merged with
ksm and things must work out automatically without admin intervention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
