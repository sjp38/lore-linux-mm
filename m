Date: Fri, 31 Jan 2003 15:13:10 -0800 (PST)
Message-Id: <20030131.151310.25151725.davem@redhat.com>
Subject: Re: hugepage patches
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  
   - need to implement either hugepage_vma()/follow_huge_addr() or
     pmd_huge()/follow_huge_pmd(), depending on whether a page's hugeness can be
     determined via pmd inspection.  Implementations of both schemes for ia32
     are here.

Remind me why we can't just look at the PTE?  Why can't
we end up doing something like:

	if (!pmd_is_huge(pmd)) {
		ptep = ...;
		if (pte_is_huge(*ptep)) {
		}
	}

Which is what all these systems besides x86 and PPC-BAT are doing.  I
don't see the real requirement for a full VMA lookup in these cases.
The page tables say fully whether we have huge stuff here or not.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
