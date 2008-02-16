Message-ID: <47B6A2BE.6080201@qumranet.com>
Date: Sat, 16 Feb 2008 10:45:50 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [patch 1/6] mmu_notifier: Core code
References: <20080215064859.384203497@sgi.com>	<20080215064932.371510599@sgi.com> <20080215193719.262c03a1.akpm@linux-foundation.org>
In-Reply-To: <20080215193719.262c03a1.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> How important is this feature to KVM?
>   

Very.  kvm pins pages that are referenced by the guest; a 64-bit guest 
will easily pin its entire memory with the kernel map.  So this is 
critical for guest swapping to actually work.

Other nice features like page migration are also enabled by this patch.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
