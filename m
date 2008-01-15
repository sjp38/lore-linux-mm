Subject: Re: [PATCH] mmu notifiers #v2
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <20080115124449.GK30812@v2.random>
References: <20080113162418.GE8736@v2.random>
	 <Pine.LNX.4.64.0801141154240.8300@schroedinger.engr.sgi.com>
	 <20080115124449.GK30812@v2.random>
Content-Type: text/plain
Date: Wed, 16 Jan 2008 07:18:53 +1100
Message-Id: <1200428333.6755.0.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-15 at 13:44 +0100, Andrea Arcangeli wrote:
> On Mon, Jan 14, 2008 at 12:02:42PM -0800, Christoph Lameter wrote:
> > Hmmm... In most of the callsites we hold a writelock on mmap_sem right?
> 
> Not in all, like Marcelo pointed out in kvm-devel, so the lowlevel
> locking can't relay on the VM locks.
> 
> About your request to schedule in the mmu notifier methods this is not
> feasible right now, the notifier is often called with the pte
> spinlocks held. I wonder if you can simply post/queue an event like a
> softirq/pdflush.

Do you have cases where it's -not- called with the PTE lock held ?
 
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
