Date: Thu, 31 Jan 2008 15:09:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random>
 <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Christoph Lameter wrote:

> > pagefault against the main linux page fault, given we already have all
> > needed serialization out of the PT lock. XPMEM is forced to do that
> 
> pt lock cannot serialize with invalidate_range since it is split. A range 
> requires locking for a series of ptes not only individual ones.

Hmmm.. May be okay after all. I see that you are only doing it on the pte 
level. This means the range callbacks are taking down a max of 512 
entries. So you have a callback for each pmd. A callback for 2M of memory?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
