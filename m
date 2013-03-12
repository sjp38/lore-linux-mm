Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 69A596B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 15:00:51 -0400 (EDT)
Date: Wed, 13 Mar 2013 04:00:12 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 0/1] mm/hugetlb: add more arch-defined huge_pte_xxx
 functions
Message-ID: <20130312190011.GC20355@linux-sh.org>
References: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Tue, Mar 12, 2013 at 07:48:25PM +0100, Gerald Schaefer wrote:
> This patch introduces those huge_pte_xxx functions and their
> implementation on all architectures supporting hugetlbfs. This change
> will be a no-op for all architectures other than s390.
> 
..

>  arch/ia64/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
>  arch/mips/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
>  arch/powerpc/include/asm/hugetlb.h | 36 ++++++++++++++++++++++++
>  arch/s390/include/asm/hugetlb.h    | 56 +++++++++++++++++++++++++++++++++++++-
>  arch/s390/include/asm/pgtable.h    | 20 --------------
>  arch/s390/mm/hugetlbpage.c         |  2 +-
>  arch/sh/include/asm/hugetlb.h      | 36 ++++++++++++++++++++++++
>  arch/sparc/include/asm/hugetlb.h   | 36 ++++++++++++++++++++++++
>  arch/tile/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
>  arch/x86/include/asm/hugetlb.h     | 36 ++++++++++++++++++++++++
>  mm/hugetlb.c                       | 23 ++++++++--------
>  11 files changed, 320 insertions(+), 33 deletions(-)
> 
None of these wrappers are doing anything profound for most platforms, so
this would be a good candidate for an asm-generic/hugetlb.h (after which
s390 can continue to be special and no one else has to care).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
