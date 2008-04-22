Date: Tue, 22 Apr 2008 13:28:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00 of 12] mmu notifier #v13
In-Reply-To: <20080422184335.GN24536@duo.random>
Message-ID: <Pine.LNX.4.64.0804221327130.3640@schroedinger.engr.sgi.com>
References: <patchbomb.1208872276@duo.random> <20080422182213.GS22493@sgi.com>
 <20080422184335.GN24536@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2008, Andrea Arcangeli wrote:

> My patch order and API backward compatible extension over the patchset
> is done to allow 2.6.26 to fully support KVM/GRU and 2.6.27 to support
> XPMEM as well. KVM/GRU won't notice any difference once the support
> for XPMEM is added, but even if the API would completely change in
> 2.6.27, that's still better than no functionality at all in 2.6.26.

Please redo the patchset with the right order. To my knowledge there is no 
chance of this getting merged for 2.6.26.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
