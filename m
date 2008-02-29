Date: Fri, 29 Feb 2008 14:09:05 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v7
Message-ID: <20080229130905.GS8091@v2.random>
References: <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <Pine.LNX.4.64.0802281456200.1152@schroedinger.engr.sgi.com> <20080229004001.GN8091@v2.random> <Pine.LNX.4.64.0802281700060.1954@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802281700060.1954@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2008 at 05:03:01PM -0800, Christoph Lameter wrote:
> I thought you wanted to get rid of the sync via pte lock?

Sure. _notify is happening inside the pt lock by coincidence, to
reduce the changes to mm/* as long as the mmu notifiers aren't
sleep capable.

> What changes to do_wp_page do you envision?

Converting it to invalidate_range_begin/end.

> What is the trouble with the current do_wp_page modifications? There is 
> no need for invalidate_page() there so far. invalidate_range() does the 
> trick there.

No trouble, it's just that I didn't want to mangle over the logic of
do_wp_page unless it was strictly required, the patch has to be
obviously safe. You need to keep that bit of your patch to make the
mmu notifiers sleepable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
