Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2FFFTEq030735
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 10:15:29 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2FFBM4l041912
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 08:11:22 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2FFEDLB008656
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 08:14:13 -0700
Date: Wed, 15 Mar 2006 07:13:28 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [discuss] Re: BUG in x86_64 hugepage support
Message-ID: <20060315151328.GD5620@us.ibm.com>
References: <20060315043544.GD5526@us.ibm.com> <200603150708.k2F78wg12642@unix-os.sc.intel.com> <20060315073046.GA5620@us.ibm.com> <4417E359.76F0.0078.0@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4417E359.76F0.0078.0@novell.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Beulich <JBeulich@novell.com>
Cc: david@gibson.dropbear.id.au, Kenneth W Chen <kenneth.w.chen@intel.com>, linux-mm@kvack.org, Andreas Kleen <ak@suse.de>, agl@us.ibm.com, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

On 15.03.2006 [09:50:17 +0100], Jan Beulich wrote:
> >diff -urpN 2.6.16-rc6-mm1/mm/hugetlb.c 2.6.16-rc6-mm1-dev/mm/hugetlb.c
> >--- 2.6.16-rc6-mm1/mm/hugetlb.c	2006-03-14 22:49:44.000000000 -0800
> >+++ 2.6.16-rc6-mm1-dev/mm/hugetlb.c	2006-03-14 22:51:31.000000000 -0800
> >@@ -740,6 +740,7 @@ void hugetlb_change_protection(struct vm
> > 			continue;
> > 		if (!pte_none(*ptep)) {
> > 			pte = huge_ptep_get_and_clear(mm, address, ptep);
> >+			pgprot_val(newprot) |= _PAGE_PSE;
> > 			pte = pte_modify(pte, newprot);
> > 			set_huge_pte_at(mm, address, ptep, pte);
> > 			lazy_mmu_prot_update(pte);
> 
> This is architecture independent code - you shouldn't be using
> _PAGE_PSE here. Probably x86-64 (and then likely also i386) should
> define their own set_huge_pte_at(), and use that# to or in the needed
> flag?

Good point, makes sense to me.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
