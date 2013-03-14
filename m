Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 00ED06B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 10:11:18 -0400 (EDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 14 Mar 2013 14:08:38 -0000
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EEB4WM53477500
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 14:11:04 GMT
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2ECrMiZ004574
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 08:53:24 -0400
Date: Thu, 14 Mar 2013 15:11:09 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 1/1] mm/hugetlb: add more arch-defined huge_pte_xxx
 functions
Message-ID: <20130314151109.5b6927ce@thinkpad>
In-Reply-To: <20130314131404.GH11631@dhcp22.suse.cz>
References: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com>
	<1363114106-30251-2-git-send-email-gerald.schaefer@de.ibm.com>
	<20130314131404.GH11631@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, "David
 S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, 14 Mar 2013 14:14:04 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 12-03-13 19:48:26, Gerald Schaefer wrote:
> > Commit abf09bed3c "s390/mm: implement software dirty bits" introduced
> > another difference in the pte layout vs. the pmd layout on s390,
> > thoroughly breaking the s390 support for hugetlbfs. This requires
> > replacing some more pte_xxx functions in mm/hugetlbfs.c with a
> > huge_pte_xxx version.
> > 
> > This patch introduces those huge_pte_xxx functions and their
> > implementation on all architectures supporting hugetlbfs. This change
> > will be a no-op for all architectures other than s390.
> > 
> > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > ---
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
> 
> Ouch, this adds a lot of code that is almost same for all archs except
> for some. Can we just make one common definition and define only those
> that differ, please?
> [...]

Ok, seems like I misinterpreted the ugliness of HAVE_ARCH_xxx vs. code
duplication. Paul Mundt also suggested going for an asm-generic/hugetlb.h
approach. I'll send a new patch soon.

Thanks,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
