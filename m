Message-ID: <47FBE7C9.9000701@qumranet.com>
Date: Wed, 09 Apr 2008 00:46:49 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
References: <patchbomb.1207669443@duo.random>
In-Reply-To: <patchbomb.1207669443@duo.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> Note that mmu_notifier_unregister may also fail with -EINTR if there are
> signal pending or the system runs out of vmalloc space or physical memory,
> only exit_mmap guarantees that any kernel module can be unloaded in presence
> of an oom condition.
>
>   

That's unusual.  What happens to the notifier?  Suppose I destroy a vm 
without exiting the process, what happens if it fires?

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
