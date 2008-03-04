Date: Tue, 4 Mar 2008 08:44:06 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080304144406.GA25467@sgi.com>
References: <20080302155457.GK8091@v2.random> <20080303032934.GA3301@wotan.suse.de> <20080303125152.GS8091@v2.random> <20080303131017.GC13138@wotan.suse.de> <20080303151859.GA19374@sgi.com> <20080303165910.GA23998@wotan.suse.de> <20080303180605.GA3552@sgi.com> <20080303184517.GA4951@wotan.suse.de> <20080303191540.GB11156@sgi.com> <1204626932.6241.41.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1204626932.6241.41.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 04, 2008 at 11:35:32AM +0100, Peter Zijlstra wrote:
> 
> On Mon, 2008-03-03 at 13:15 -0600, Jack Steiner wrote:
> 
> > I haven't thought about locking requirements for the radix tree. Most accesses
> > would be read-only & updates infrequent. Any chance of an RCU-based radix
> > implementation?  Otherwise, don't we add the potential for hot locks/cachelines
> > for threaded applications ???
> 
> The current radix tree implementation in the kernel is RCU capable. We
> just don't have many RCU users yet.

Ahhh. You are right. I thought I looked but obviously missed it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
