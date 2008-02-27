Date: Wed, 27 Feb 2008 14:23:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080219133405.GH7128@v2.random>
Message-ID: <Pine.LNX.4.64.0802271421480.13186@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com>
 <200802191954.14874.nickpiggin@yahoo.com.au> <20080219133405.GH7128@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008, Andrea Arcangeli wrote:

> Yes, that's why I kept maintaining my patch and I posted the last
> revision to Andrew. I use pte/tlb locking of the core VM, it's
> unintrusive and obviously safe. Furthermore it can be extended with
> Christoph's stuff in a 100% backwards compatible fashion later if needed.

How would that work? You rely on the pte locking. Thus calls are all in an 
atomic context. I think we need a general scheme that allows sleeping when 
references are invalidates. Even the GRU has performance issues when using 
the KVM patch.


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
