Subject: Re: [PATCH] mmu notifiers #v8 + xpmem
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080302160351.GL8091@v2.random>
References: <20080219084357.GA22249@wotan.suse.de>
	 <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de>
	 <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random>
	 <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random>
	 <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random>
	 <20080302155457.GK8091@v2.random>  <20080302160351.GL8091@v2.random>
Content-Type: text/plain
Date: Sun, 02 Mar 2008 17:23:58 +0100
Message-Id: <1204475038.6240.47.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-03-02 at 17:03 +0100, Andrea Arcangeli wrote:

> 4) Then finally the mmu_notifier_unregister must be dropped to make the
> mmu notifier sleep capable with RCU in the mmu_notifier() fast path.

Or require PREEMPTIBLE_RCU, that can handle sleeps..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
