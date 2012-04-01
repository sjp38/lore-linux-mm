Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 069616B00E8
	for <linux-mm@kvack.org>; Sun,  1 Apr 2012 08:33:06 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so1768924vcb.14
        for <linux-mm@kvack.org>; Sun, 01 Apr 2012 05:33:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203311612.q2VGCqPA012710@farm-0012.internal.tilera.com>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
	<CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
	<201203311334.q2VDYGiL005854@farm-0012.internal.tilera.com>
	<CAJd=RBDEAMgDviSwugt7dHKPGXCCF5jQSDtHdXvt5VnSBmK3bA@mail.gmail.com>
	<201203311612.q2VGCqPA012710@farm-0012.internal.tilera.com>
Date: Sun, 1 Apr 2012 20:33:05 +0800
Message-ID: <CAJd=RBDqQ2jwxyVgn-WwoJfu0vOs9YUHfKxkcqUczr=cnk+8wg@mail.gmail.com>
Subject: Re: [PATCH v3] arch/tile: support multiple huge page sizes dynamically
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Sat, Mar 31, 2012 at 3:37 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> This change adds support for a new "super" bit in the PTE, and a
> new arch_make_huge_pte() method called from make_huge_pte().
> The Tilera hypervisor sees the bit set at a given level of the page
> table and gangs together 4, 16, or 64 consecutive pages from
> that level of the hierarchy to create a larger TLB entry.
>
> One extra "super" page size can be specified at each of the
> three levels of the page table hierarchy on tilegx, using the
> "hugepagesz" argument on the boot command line. =C2=A0A new hypervisor
> API is added to allow Linux to tell the hypervisor how many PTEs
> to gang together at each level of the page table.
>
> To allow pre-allocating huge pages larger than the buddy allocator
> can handle, this change modifies the Tilera bootmem support to
> put all of memory on tilegx platforms into bootmem.
>
> As part of this change I eliminate the vestigial CONFIG_HIGHPTE
> support, which never worked anyway, and eliminate the hv_page_size()
> API in favor of the standard vma_kernel_pagesize() API.
>
> Reviewed-by: Hillf Danton <dhillf@gmail.com>
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> This version of the patch adds a generic no-op definition to
> <linux/hugetlb.h> if "arch_make_huge_pte" is not #defined. =C2=A0I'm foll=
owing
> Linus's model in https://lkml.org/lkml/2012/1/19/443 which says you creat=
e
> the inline, then "#define func func" to indicate that the function exists=
.
>
> Hillf, let me know if you want to provide an Acked-by, or I'll leave it
> as Reviewed-by. =C2=A0I'm glad you didn't like the v2 patch;
>
Frankly I like this work, if merged, many tile users benefit.

And a few more words,
1, the Reviewed-by tag does not match what I did, really, and
over 98% of this work should be reviewed by tile gurus IMO.

2, this work was delivered in a monolithic huge patch, and it is hard
to be reviewed. The rule of thumb is to split it into several parts, then
reviewers read a good story, chapter after another.

3, I look forward to reading the mm/hugetlb.c chapter.

Good weekend
-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
