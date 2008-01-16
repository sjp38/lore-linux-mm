Date: Wed, 16 Jan 2008 02:06:01 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v2
Message-ID: <20080116010601.GF7059@v2.random>
References: <20080113162418.GE8736@v2.random> <Pine.LNX.4.64.0801141154240.8300@schroedinger.engr.sgi.com> <20080115124449.GK30812@v2.random> <1200428333.6755.0.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1200428333.6755.0.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 07:18:53AM +1100, Benjamin Herrenschmidt wrote:
> Do you have cases where it's -not- called with the PTE lock held ?

For invalidate_page no because currently it's only called next to the
ptep_get_and_clear that modifies the pte and requires the pte
lock. invalidate_range/release are called w/o pte lock held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
