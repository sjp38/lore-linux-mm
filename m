Date: Thu, 6 Mar 2008 03:59:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080306025908.GC27150@wotan.suse.de>
References: <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303032934.GA3301@wotan.suse.de> <Pine.LNX.4.64.0803031058230.6917@schroedinger.engr.sgi.com> <20080305003722.GG1510@wotan.suse.de> <Pine.LNX.4.64.0803051048100.29794@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803051048100.29794@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Jack Steiner <steiner@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Mar 05, 2008 at 10:48:24AM -0800, Christoph Lameter wrote:
> On Wed, 5 Mar 2008, Nick Piggin wrote:
> 
> > Um, it's bound to the *Linux page tables*, yes. And I have no idea why
> > you would use the paravirt ops for this.
> 
> paravirt ops allows interception of page table operations?

Maybe possible but it's totally the wrong API for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
