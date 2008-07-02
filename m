Date: Wed, 2 Jul 2008 03:59:50 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0 of 3] mmu notifier v18 for -mm
Message-ID: <20080702085950.GV9696@sgi.com>
References: <patchbomb.1214440016@duo.random> <20080701214415.b3f93706.akpm@linux-foundation.org> <486B0B0F.5010605@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <486B0B0F.5010605@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Avi Kivity <avi@qumranet.com>, Andrea Arcangeli <andrea@qumranet.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Izik Eidus <izike@qumranet.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 02, 2008 at 07:58:55AM +0300, Avi Kivity wrote:
> Andrew Morton wrote:
>> On Thu, 26 Jun 2008 02:26:56 +0200 Andrea Arcangeli <andrea@qumranet.com> wrote:
>>
>>> Full patchset including other XPMEM support patches can be found here:
>>>
>>> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.26-rc7/mmu-notifier-v18
>>
>> I'm a bit concerned about merging the first three patches when there
>> are eleven more patches of which some, afacit, are required to make
>> these three actually useful.  Committing these three would be signing a
>> blank cheque.
>>
>>   
>
> The first three are useful for kvm, gru, and likely drm and rdma nics.
>
> It is only xpmem which requires the other eleven patches.
>
>> Because if we hit strong objections with the later patches we end up in a
>> cant-go-forward, cant-go-backward situation.

SGI decided we need a functional GRU more than an enhanced XPMEM.
We have, for 7 years now, told our customers that using XPMEM results
in pages being permanently pinned and swap being disabled, and they
have been accepting of that.  We have also put other restrictions on
what parts of the address space could be exported.  It is not ideal,
but it is functional.

To work with distro kernels, we have requested 3 EXPORT_SYMBOL_GPL()s
from SuSE (SLES-10) and 2 from RedHat (RHEL-5).  With that and an
LD_PRELOAD library, we can support most types of clone2()s safely and
the documentation lists what is not supported (like mmap() into the
middle of a region of memory that has been used for calculations).

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
