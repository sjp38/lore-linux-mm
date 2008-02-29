Date: Fri, 29 Feb 2008 11:46:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v7
In-Reply-To: <20080229130905.GS8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802291145390.11292@schroedinger.engr.sgi.com>
References: <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
 <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <Pine.LNX.4.64.0802281456200.1152@schroedinger.engr.sgi.com>
 <20080229004001.GN8091@v2.random> <Pine.LNX.4.64.0802281700060.1954@schroedinger.engr.sgi.com>
 <20080229130905.GS8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Andrea Arcangeli wrote:

> On Thu, Feb 28, 2008 at 05:03:01PM -0800, Christoph Lameter wrote:
> > I thought you wanted to get rid of the sync via pte lock?
> 
> Sure. _notify is happening inside the pt lock by coincidence, to
> reduce the changes to mm/* as long as the mmu notifiers aren't
> sleep capable.

Ok if this is a coincidence then it would be better to separate the 
notifier callouts from the pte macro calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
