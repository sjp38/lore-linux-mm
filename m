Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 542086B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 15:28:25 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 12 Mar 2013 19:25:44 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7D29017D802D
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 19:28:59 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2CJSBwr29425900
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 19:28:11 GMT
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2CIKnCV023165
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 14:20:50 -0400
Date: Tue, 12 Mar 2013 20:28:16 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 0/1] mm/hugetlb: add more arch-defined huge_pte_xxx
 functions
Message-ID: <20130312202816.0890348c@thinkpad>
In-Reply-To: <20130312190011.GC20355@linux-sh.org>
References: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com>
	<20130312190011.GC20355@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Wed, 13 Mar 2013 04:00:12 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> On Tue, Mar 12, 2013 at 07:48:25PM +0100, Gerald Schaefer wrote:
> > This patch introduces those huge_pte_xxx functions and their
> > implementation on all architectures supporting hugetlbfs. This change
> > will be a no-op for all architectures other than s390.
> > 
> ..
> 
> >  arch/ia64/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
> >  arch/mips/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
> >  arch/powerpc/include/asm/hugetlb.h | 36 ++++++++++++++++++++++++
> >  arch/s390/include/asm/hugetlb.h    | 56 +++++++++++++++++++++++++++++++++++++-
> >  arch/s390/include/asm/pgtable.h    | 20 --------------
> >  arch/s390/mm/hugetlbpage.c         |  2 +-
> >  arch/sh/include/asm/hugetlb.h      | 36 ++++++++++++++++++++++++
> >  arch/sparc/include/asm/hugetlb.h   | 36 ++++++++++++++++++++++++
> >  arch/tile/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
> >  arch/x86/include/asm/hugetlb.h     | 36 ++++++++++++++++++++++++
> >  mm/hugetlb.c                       | 23 ++++++++--------
> >  11 files changed, 320 insertions(+), 33 deletions(-)
> > 
> None of these wrappers are doing anything profound for most platforms, so
> this would be a good candidate for an asm-generic/hugetlb.h (after which
> s390 can continue to be special and no one else has to care).

Yes, that was also my first idea, but I vaguely remembered some discussion
with Andrew when I sent the original s390 hugetlb support patch (which also
went for the asm-generic approach). So I tried to dig out that thread, and
it turned out that the ugliness of ARCH_HAS_xxx actually resulted in my
original patch to be changed into removing lots of those and therefore
creating the individual arch header files, for the sake of readability and
maintainability. So I guess it would be straightforward to extend those
header files now, instead of re-introducing some of the ugliness.

See also here http://marc.info/?l=linux-kernel&m=120536577402075&w=2 and
here http://marc.info/?l=linux-kernel&m=120732788201196&w=2.

Thanks,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
