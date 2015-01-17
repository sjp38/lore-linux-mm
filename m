Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id ACC136B0032
	for <linux-mm@kvack.org>; Sat, 17 Jan 2015 01:40:34 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wp4so1324761obc.6
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 22:40:34 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id x8si2095849obw.51.2015.01.16.22.40.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 22:40:33 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YCN3g-003Rgr-Jb
	for linux-mm@kvack.org; Sat, 17 Jan 2015 06:40:32 +0000
Date: Fri, 16 Jan 2015 22:40:23 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2015-01-16-15-50 uploaded
Message-ID: <20150117064023.GA5743@roeck-us.net>
References: <54b9a3ce.lQ94nh84G4XJawsQ%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54b9a3ce.lQ94nh84G4XJawsQ%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Jan 16, 2015 at 03:50:38PM -0800, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2015-01-16-15-50 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

This version is a bit worse than usual.

Build results:
	total: 133 pass: 113 fail: 20
Failed builds:
	alpha:defconfig
	alpha:allmodconfig
	m32r:defconfig
	m68k:defconfig
	m68k:allmodconfig
	m68k:sun3_defconfig
	m68k:m5475evb_defconfig
	microblaze:mmu_defconfig
	mips:allmodconfig
	parisc:defconfig
	parisc:generic-32bit_defconfig
	parisc:a500_defconfig
	parisc:generic-64bit_defconfig
	powerpc:cell_defconfig
	powerpc:mpc85xx_defconfig
	powerpc:mpc85xx_smp_defconfig
	powerpc:cell_defconfig
	powerpc:mpc85xx_defconfig
	powerpc:mpc85xx_smp_defconfig
	sparc32:defconfig
Qemu tests:
	total: 30 pass: 18 fail: 12
Failed tests:
	alpha:alpha_defconfig
	microblaze:microblaze_defconfig
	microblaze:microblazeel_defconfig
	mips:mips_malta_smp_defconfig
	mips64:mips_malta64_smp_defconfig
	powerpc:ppc_book3s_smp_defconfig
	powerpc:ppc64_book3s_smp_defconfig
	sh:sh_defconfig
	sparc32:sparc_defconfig
	sparc32:sparc_smp_defconfig
	x86:x86_pc_defconfig
	x86_64:x86_64_pc_defconfig

Details are available at http://server.roeck-us.net:8010/builders; look for the
'mmotm' logs.

Patches identified as bad by bisect (see below for bisect logs):

3ecd42e200dc mm/hugetlb: reduce arch dependent code around follow_huge_*
c824a9dc5e88 mm: account pmd page tables to the process
825e778f321e mm/slub: optimize alloc/free fastpath by removing preemption on/off
df67fb4bb2d6 mm: drop vm_ops->remap_pages and generic_file_remap_pages() stub

Guenter

---
bisect logs:

ppc:

# bad: [59f7a5af1a6c9e19c6e5152f26548c494a2d7338] pci: test for unexpectedly disabled bridges
# good: [eaa27f34e91a14cdceed26ed6c6793ec1d186115] linux 3.19-rc4
git bisect start 'HEAD' 'v3.19-rc4'
# bad: [374591eb9f19a0805a3e1cc595fd30275d0f5e34] arm: add pmd_mkclean for THP
git bisect bad 374591eb9f19a0805a3e1cc595fd30275d0f5e34
# good: [66b849de48203a58decbec70b4b02ec85d5fc32b] memcg: zap memcg_name argument of memcg_create_kmem_cache
git bisect good 66b849de48203a58decbec70b4b02ec85d5fc32b
# bad: [b4ff5dfee2dc67a3c0c472df2b37449bcf617124] fs: make shrinker memcg aware
git bisect bad b4ff5dfee2dc67a3c0c472df2b37449bcf617124
# bad: [766b92ec2b19d5001dd0c251b834bccb8cc8c51b] mm: numa: do not dereference pmd outside of the lock during NUMA hinting fault
git bisect bad 766b92ec2b19d5001dd0c251b834bccb8cc8c51b
# good: [0c4a0839fab29f8bb71fb367f716b09974710c56] kmemcheck: move hook into __alloc_pages_nodemask() for the page allocator
git bisect good 0c4a0839fab29f8bb71fb367f716b09974710c56
# bad: [14dbc43ae568875fd8faf5d2749dfd1cc27f375c] mm/hugetlb: take page table lock in follow_huge_pmd()
git bisect bad 14dbc43ae568875fd8faf5d2749dfd1cc27f375c
# good: [c6d31af33e763127e7b9e5af73a2255d0f3e3b39] mm, vmscan: wake up all pfmemalloc-throttled processes at once
git bisect good c6d31af33e763127e7b9e5af73a2255d0f3e3b39
# bad: [ac67e0f46740fece93761c0b17437ebf1972d3c9] mm/hugetlb: pmd_huge() returns true for non-present hugepage
git bisect bad ac67e0f46740fece93761c0b17437ebf1972d3c9
# bad: [3ecd42e200dc8afcdcea809b1546783e3dc271be] mm/hugetlb: reduce arch dependent code around follow_huge_*
git bisect bad 3ecd42e200dc8afcdcea809b1546783e3dc271be
# first bad commit: [3ecd42e200dc8afcdcea809b1546783e3dc271be] mm/hugetlb: reduce arch dependent code around follow_huge_*

parisc:

# bad: [59f7a5af1a6c9e19c6e5152f26548c494a2d7338] pci: test for unexpectedly disabled bridges
# good: [eaa27f34e91a14cdceed26ed6c6793ec1d186115] linux 3.19-rc4
git bisect start 'HEAD' 'v3.19-rc4'
# bad: [374591eb9f19a0805a3e1cc595fd30275d0f5e34] arm: add pmd_mkclean for THP
git bisect bad 374591eb9f19a0805a3e1cc595fd30275d0f5e34
# good: [66b849de48203a58decbec70b4b02ec85d5fc32b] memcg: zap memcg_name argument of memcg_create_kmem_cache
git bisect good 66b849de48203a58decbec70b4b02ec85d5fc32b
# good: [b4ff5dfee2dc67a3c0c472df2b37449bcf617124] fs: make shrinker memcg aware
git bisect good b4ff5dfee2dc67a3c0c472df2b37449bcf617124
# good: [f10b1f4851a4c5ebf006c043ac541c0f5041e9b1] fs: shrinker: always scan at least one object of each type
git bisect good f10b1f4851a4c5ebf006c043ac541c0f5041e9b1
# bad: [beaaa51193ba7476901a0751edbe48c4c5eae620] mm: vmscan: fix the page state calculation in too_many_isolated
git bisect bad beaaa51193ba7476901a0751edbe48c4c5eae620
# bad: [61182191d3e8732d59a7075a0dfba794eb214705] page_writeback: cleanup mess around cancel_dirty_page()
git bisect bad 61182191d3e8732d59a7075a0dfba794eb214705
# good: [5bce03e66f2ee510be64c27b86b6114c8c1b52e7] mm: pagemap_read: limit scan to virtual region being asked
git bisect good 5bce03e66f2ee510be64c27b86b6114c8c1b52e7
# bad: [7962f8a4bf53cc6cca30e4d138d72f529b13eedd] page_writeback: put account_page_redirty() after set_page_dirty()
git bisect bad 7962f8a4bf53cc6cca30e4d138d72f529b13eedd
# bad: [c824a9dc5e8821ce083652d4f728e804161d3dd0] mm: account pmd page tables to the process
git bisect bad c824a9dc5e8821ce083652d4f728e804161d3dd0
# first bad commit: [c824a9dc5e8821ce083652d4f728e804161d3dd0] mm: account pmd page tables to the process

mips:

# bad: [59f7a5af1a6c9e19c6e5152f26548c494a2d7338] pci: test for unexpectedly disabled bridges
# good: [eaa27f34e91a14cdceed26ed6c6793ec1d186115] linux 3.19-rc4
git bisect start 'HEAD' 'v3.19-rc4'
# bad: [374591eb9f19a0805a3e1cc595fd30275d0f5e34] arm: add pmd_mkclean for THP
git bisect bad 374591eb9f19a0805a3e1cc595fd30275d0f5e34
# bad: [66b849de48203a58decbec70b4b02ec85d5fc32b] memcg: zap memcg_name argument of memcg_create_kmem_cache
git bisect bad 66b849de48203a58decbec70b4b02ec85d5fc32b
# good: [1bb1c80a9f3bf3ee90729ea4a048728b22f7c7e9] mm: replace remap_file_pages() syscall with emulation
git bisect good 1bb1c80a9f3bf3ee90729ea4a048728b22f7c7e9
# bad: [13e9a74879b8f71d81726b6a9dace1da0cc770d3] metag: drop _PAGE_FILE and pte_file()-related helpers
git bisect bad 13e9a74879b8f71d81726b6a9dace1da0cc770d3
# bad: [60ec045c7091d034fa3c13f8a449f7a68d0ec37f] arc-drop-_page_file-and-pte_file-related-helpers-fix
git bisect bad 60ec045c7091d034fa3c13f8a449f7a68d0ec37f
# bad: [e0594d89beda9d7027e5e13603065ba0b68e339e] rmap: drop support of non-linear mappings
git bisect bad e0594d89beda9d7027e5e13603065ba0b68e339e
# good: [eeb84bbe41d06868a5b9a0db3aeabe23b098aa1a] mm: drop support of non-linear mapping from fault codepath
git bisect good eeb84bbe41d06868a5b9a0db3aeabe23b098aa1a
# bad: [ee23dbe4f96ed1bb87bb45c38682768891b5b871] proc: drop handling non-linear mappings
git bisect bad ee23dbe4f96ed1bb87bb45c38682768891b5b871
# bad: [df67fb4bb2d6dfddc894743585d0c78bf87d29d3] mm: drop vm_ops->remap_pages and generic_file_remap_pages() stub
git bisect bad df67fb4bb2d6dfddc894743585d0c78bf87d29d3
# first bad commit: [df67fb4bb2d6dfddc894743585d0c78bf87d29d3] mm: drop vm_ops->remap_pages and generic_file_remap_pages() stub

qemu arm:

# bad: [59f7a5af1a6c9e19c6e5152f26548c494a2d7338] pci: test for unexpectedly disabled bridges
# good: [eaa27f34e91a14cdceed26ed6c6793ec1d186115] linux 3.19-rc4
git bisect start 'HEAD' 'v3.19-rc4'
# bad: [374591eb9f19a0805a3e1cc595fd30275d0f5e34] arm: add pmd_mkclean for THP
git bisect bad 374591eb9f19a0805a3e1cc595fd30275d0f5e34
# good: [66b849de48203a58decbec70b4b02ec85d5fc32b] memcg: zap memcg_name argument of memcg_create_kmem_cache
git bisect good 66b849de48203a58decbec70b4b02ec85d5fc32b
# good: [b4ff5dfee2dc67a3c0c472df2b37449bcf617124] fs: make shrinker memcg aware
git bisect good b4ff5dfee2dc67a3c0c472df2b37449bcf617124
# good: [f10b1f4851a4c5ebf006c043ac541c0f5041e9b1] fs: shrinker: always scan at least one object of each type
git bisect good f10b1f4851a4c5ebf006c043ac541c0f5041e9b1
# bad: [beaaa51193ba7476901a0751edbe48c4c5eae620] mm: vmscan: fix the page state calculation in too_many_isolated
git bisect bad beaaa51193ba7476901a0751edbe48c4c5eae620
# bad: [61182191d3e8732d59a7075a0dfba794eb214705] page_writeback: cleanup mess around cancel_dirty_page()
git bisect bad 61182191d3e8732d59a7075a0dfba794eb214705
# good: [5bce03e66f2ee510be64c27b86b6114c8c1b52e7] mm: pagemap_read: limit scan to virtual region being asked
git bisect good 5bce03e66f2ee510be64c27b86b6114c8c1b52e7
# bad: [7962f8a4bf53cc6cca30e4d138d72f529b13eedd] page_writeback: put account_page_redirty() after set_page_dirty()
git bisect bad 7962f8a4bf53cc6cca30e4d138d72f529b13eedd
# bad: [c824a9dc5e8821ce083652d4f728e804161d3dd0] mm: account pmd page tables to the process
git bisect bad c824a9dc5e8821ce083652d4f728e804161d3dd0
# first bad commit: [c824a9dc5e8821ce083652d4f728e804161d3dd0] mm: account pmd page tables to the process

qemu x86_64 (as well as x86_32 and and most likely mips):

# bad: [59f7a5af1a6c9e19c6e5152f26548c494a2d7338] pci: test for unexpectedly disabled bridges
# good: [eaa27f34e91a14cdceed26ed6c6793ec1d186115] linux 3.19-rc4
git bisect start 'HEAD' 'v3.19-rc4'
# bad: [374591eb9f19a0805a3e1cc595fd30275d0f5e34] arm: add pmd_mkclean for THP
git bisect bad 374591eb9f19a0805a3e1cc595fd30275d0f5e34
# bad: [66b849de48203a58decbec70b4b02ec85d5fc32b] memcg: zap memcg_name argument of memcg_create_kmem_cache
git bisect bad 66b849de48203a58decbec70b4b02ec85d5fc32b
# bad: [1bb1c80a9f3bf3ee90729ea4a048728b22f7c7e9] mm: replace remap_file_pages() syscall with emulation
git bisect bad 1bb1c80a9f3bf3ee90729ea4a048728b22f7c7e9
# good: [d693317ef138db88446b3e9f0f65f424fd601046] ocfs2: xattr: remove unused function
git bisect good d693317ef138db88446b3e9f0f65f424fd601046
# good: [b0ac27f754e58851bc34236c5f15deab5ba5439a] ocfs2: implement ocfs2_direct_IO_write
git bisect good b0ac27f754e58851bc34236c5f15deab5ba5439a
# good: [3e069709979378600e1fc743105df008b683fc67] fsioctl.c: make generic_block_fiemap() signal-tolerant
git bisect good 3e069709979378600e1fc743105df008b683fc67
# bad: [825e778f321e376dd4c083a0f0cef9281cdcfefc] mm/slub: optimize alloc/free fastpath by removing preemption on/off
git bisect bad 825e778f321e376dd4c083a0f0cef9281cdcfefc
# good: [9084e3fb91012d903b2d74fc95605a37db4d7682] add -mmN to EXTRAVERSION
git bisect good 9084e3fb91012d903b2d74fc95605a37db4d7682
# first bad commit: [825e778f321e376dd4c083a0f0cef9281cdcfefc] mm/slub: optimize alloc/free fastpath by removing preemption on/off

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
