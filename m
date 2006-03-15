Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2FFGGsS031781
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 10:16:16 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2FFHtJm154818
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 08:17:55 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2FFExZx013601
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 08:14:59 -0700
Date: Wed, 15 Mar 2006 07:14:14 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [discuss] Re: BUG in x86_64 hugepage support
Message-ID: <20060315151414.GE5620@us.ibm.com>
References: <4417E359.76F0.0078.0@novell.com> <200603151003.k2FA30g14232@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200603151003.k2FA30g14232@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Jan Beulich' <JBeulich@novell.com>, david@gibson.dropbear.id.au, linux-mm@kvack.org, Andreas Kleen <ak@suse.de>, agl@us.ibm.com, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

On 15.03.2006 [02:03:00 -0800], Chen, Kenneth W wrote:
> Nishanth Aravamudan wrote on Tuesday, March 14, 2006 11:31 PM
> > Description: We currently fail mprotect testing in libhugetlbfs because
> > the PSE bit in the hugepage PTEs gets unset. In the case where we know
> > that a filled hugetlb PTE is going to have its protection changed, make
> > sure it stays a hugetlb PTE by setting the PSE bit in the new protection
> > flags.
> 
> Jan Beulich wrote on Wednesday, March 15, 2006 12:50 AM
> > This is architecture independent code - you shouldn't be using
> > _PAGE_PSE here. Probably x86-64 (and then likely also i386) should
> > define their own set_huge_pte_at(), and use that# to or in the
> > needed flag?
> 
> 
> Yeah, that will do.  i386, x86_64 should also clean up pte_mkhuge()
> macro.  The unconditional setting of _PAGE_PRESENT bit was a leftover
> stuff from the good'old day of pre-faulting hugetlb page.  

Patch looks correct, I'll reboot with it applied and make sure it fixes
the BUGs (and doesn't affect any of the other tests).

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
