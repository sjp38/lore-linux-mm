Date: Sat, 16 Feb 2008 00:56:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-Id: <20080216005653.353a62dc.akpm@linux-foundation.org>
In-Reply-To: <47B6A2BE.6080201@qumranet.com>
References: <20080215064859.384203497@sgi.com>
	<20080215064932.371510599@sgi.com>
	<20080215193719.262c03a1.akpm@linux-foundation.org>
	<47B6A2BE.6080201@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008 10:45:50 +0200 Avi Kivity <avi@qumranet.com> wrote:

> Andrew Morton wrote:
> > How important is this feature to KVM?
> >   
> 
> Very.  kvm pins pages that are referenced by the guest;

hm.  Why does it do that?

> a 64-bit guest 
> will easily pin its entire memory with the kernel map.

>  So this is 
> critical for guest swapping to actually work.

Curious.  If KVM can release guest pages at the request of this notifier so
that they can be swapped out, why can't it release them by default, and
allow swapping to proceed?

> 
> Other nice features like page migration are also enabled by this patch.
> 

We already have page migration.  Do you mean page-migration-when-using-kvm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
