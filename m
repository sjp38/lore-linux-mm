Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id D0F1C6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 11:33:05 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so3305041eek.4
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 08:33:05 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id d46si20225397eeo.60.2014.01.13.08.33.01
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 08:33:05 -0800 (PST)
Date: Mon, 13 Jan 2014 18:32:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4] powerpc: thp: Fix crash on mremap
Message-ID: <20140113163254.GA4658@node.dhcp.inet.fi>
References: <1389593064-32664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389593064-32664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Jan 13, 2014 at 11:34:24AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch fix the below crash
> 
> NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
> LR [c0000000000439ac] .hash_page+0x18c/0x5e0
> ...
> Call Trace:
> [c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
> [437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
> [437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58
> 
> On ppc64 we use the pgtable for storing the hpte slot information and
> store address to the pgtable at a constant offset (PTRS_PER_PMD) from
> pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
> the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
> from new pmd.
> 
> We also want to move the withdraw and deposit before the set_pmd so
> that, when page fault find the pmd as trans huge we can be sure that
> pgtable can be located at the offset.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
