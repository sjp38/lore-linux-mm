Date: Wed, 16 Jan 2008 12:42:55 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] mmu notifiers #v2
Message-ID: <20080116124256.44033d48@bree.surriel.com>
In-Reply-To: <20080113162418.GE8736@v2.random>
References: <20080113162418.GE8736@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, clameter@sgi.com, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jan 2008 17:24:18 +0100
Andrea Arcangeli <andrea@qumranet.com> wrote:

> In my basic initial patch I only track the tlb flushes which should be
> the minimum required to have a nice linux-VM controlled swapping
> behavior of the KVM gphysical memory. 

I have a vaguely related question on KVM swapping.

Do page accesses inside KVM guests get propagated to the host
OS, so Linux can choose a reasonable page for eviction, or is
the pageout of KVM guest pages essentially random?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
