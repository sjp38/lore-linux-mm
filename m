Date: Thu, 21 Feb 2008 10:10:28 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080221161028.GA14220@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080221144023.GC9427@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

> I really want suggestions on Jack's concern about issuing an
> invalidate per pte entry or per-pte instead of per-range. I'll answer
> that in a separate email. For KVM my patch is already close to optimal
> because each single spte invalidate requires a fixed amount of work,
> but for GRU a large invalidate-range would be more efficient.
>
> To address the GRU _valid_ concern, I can create a second version of
> my patch with range_begin/end instead of invalidate_pages, that still

I don't know how much significance to place on this data, but it is
a real data point.

I ran the GRU regression test suite on kernels with both types of
mmu_notifiers. The kernel/driver using Christoph's patch had
1/7 the number of TLB invalidates as Andrea's patch.

This reduction is due to both differences I mentioned yesterday:
	- different location of callout for address space teardown
	- range callouts

Unfortunately, the current driver does not allow me to quantify
which of the differences is most significant.

Also, I'll try to post the driver within the next few days. It is
still in development but it compiles and can successfully run most
workloads on a system simulator.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
