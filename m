Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 857396B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 12:13:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m5so170128184pfc.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 09:13:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e68si21268995pfe.273.2017.05.23.09.13.55
        for <linux-mm@kvack.org>;
        Tue, 23 May 2017 09:13:55 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v3 3/6] mm/hugetlb: add size parameter to huge_pte_offset()
References: <201705231817.OSRI6iib%fengguang.wu@intel.com>
Date: Tue, 23 May 2017 17:13:52 +0100
In-Reply-To: <201705231817.OSRI6iib%fengguang.wu@intel.com> (kbuild test
	robot's message of "Tue, 23 May 2017 18:04:42 +0800")
Message-ID: <87wp97ft4v.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, hillf.zj@alibaba-inc.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <"cme tcalf"@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>

kbuild test robot <lkp@intel.com> writes:

> Hi Punit,
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.12-rc2 next-20170523]
> [cannot apply to mmotm/master]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Punit-Agrawal/Support-for-contiguous-pte-hugepages/20170523-142407
> config: arm64-defconfig (attached as .config)
> compiler: aarch64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm64 
>
> All errors (new ones prefixed by >>):
>
>    arch/arm64/mm/hugetlbpage.c: In function 'huge_ptep_get_and_clear':
>>> arch/arm64/mm/hugetlbpage.c:200:10: error: too few arguments to function 'huge_pte_offset'
>       cpte = huge_pte_offset(mm, addr);
>              ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c:135:8: note: declared here
>     pte_t *huge_pte_offset(struct mm_struct *mm,
>            ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c: In function 'huge_ptep_set_access_flags':
>    arch/arm64/mm/hugetlbpage.c:238:10: error: too few arguments to function 'huge_pte_offset'
>       cpte = huge_pte_offset(vma->vm_mm, addr);
>              ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c:135:8: note: declared here
>     pte_t *huge_pte_offset(struct mm_struct *mm,
>            ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c: In function 'huge_ptep_set_wrprotect':
>    arch/arm64/mm/hugetlbpage.c:263:10: error: too few arguments to function 'huge_pte_offset'
>       cpte = huge_pte_offset(mm, addr);
>              ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c:135:8: note: declared here
>     pte_t *huge_pte_offset(struct mm_struct *mm,
>            ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c: In function 'huge_ptep_clear_flush':
>    arch/arm64/mm/hugetlbpage.c:280:10: error: too few arguments to function 'huge_pte_offset'
>       cpte = huge_pte_offset(vma->vm_mm, addr);
>              ^~~~~~~~~~~~~~~
>    arch/arm64/mm/hugetlbpage.c:135:8: note: declared here
>     pte_t *huge_pte_offset(struct mm_struct *mm,
>            ^~~~~~~~~~~~~~~

Ok, so we haven't quite managed to remove the dependency of this patch
on the following arm64 changes[0].

I'll post a new version fixing this failure soon.

[0] https://www.spinics.net/lists/arm-kernel/msg582758.html

>
> vim +/huge_pte_offset +200 arch/arm64/mm/hugetlbpage.c
>
> 66b3923a David Woods 2015-12-17  194  	if (pte_cont(*ptep)) {
> 66b3923a David Woods 2015-12-17  195  		int ncontig, i;
> 66b3923a David Woods 2015-12-17  196  		size_t pgsize;
> 66b3923a David Woods 2015-12-17  197  		pte_t *cpte;
> 66b3923a David Woods 2015-12-17  198  		bool is_dirty = false;
> 66b3923a David Woods 2015-12-17  199  
> 66b3923a David Woods 2015-12-17 @200  		cpte = huge_pte_offset(mm, addr);
> 66b3923a David Woods 2015-12-17  201  		ncontig = find_num_contig(mm, addr, cpte, *cpte, &pgsize);
> 66b3923a David Woods 2015-12-17  202  		/* save the 1st pte to return */
> 66b3923a David Woods 2015-12-17  203  		pte = ptep_get_and_clear(mm, addr, cpte);
>
> :::::: The code at line 200 was first introduced by commit
> :::::: 66b3923a1a0f77a563b43f43f6ad091354abbfe9 arm64: hugetlb: add support for PTE contiguous bit
>
> :::::: TO: David Woods <dwoods@ezchip.com>
> :::::: CC: Will Deacon <will.deacon@arm.com>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
