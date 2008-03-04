Subject: Re: [PATCH] mmu notifiers #v8
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080303191540.GB11156@sgi.com>
References: <20080221161028.GA14220@sgi.com>
	 <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
	 <20080303032934.GA3301@wotan.suse.de> <20080303125152.GS8091@v2.random>
	 <20080303131017.GC13138@wotan.suse.de> <20080303151859.GA19374@sgi.com>
	 <20080303165910.GA23998@wotan.suse.de> <20080303180605.GA3552@sgi.com>
	 <20080303184517.GA4951@wotan.suse.de>  <20080303191540.GB11156@sgi.com>
Content-Type: text/plain
Date: Tue, 04 Mar 2008 11:35:32 +0100
Message-Id: <1204626932.6241.41.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-03 at 13:15 -0600, Jack Steiner wrote:

> I haven't thought about locking requirements for the radix tree. Most accesses
> would be read-only & updates infrequent. Any chance of an RCU-based radix
> implementation?  Otherwise, don't we add the potential for hot locks/cachelines
> for threaded applications ???

The current radix tree implementation in the kernel is RCU capable. We
just don't have many RCU users yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
