Date: Thu, 31 Jan 2008 17:37:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080131232842.GQ7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801311733140.24297@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random>
 <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
 <20080131232842.GQ7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008, Andrea Arcangeli wrote:

> I appreciate the review! I hope my entirely bug free and
> strightforward #v5 will strongly increase the probability of getting
> this in sooner than later. If something else it shows the approach I
> prefer to cover GRU/KVM 100%, leaving the overkill mutex locking
> requirements only to the mmu notifier users that can't deal with the
> scalar and finegrined and already-taken/trashed PT lock.

Mutex locking? Could you be more specific?

I hope you will continue to do reviews of the other mmu notifier patchset?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
