Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DCB176B006C
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:20:06 -0400 (EDT)
Received: by widdi4 with SMTP id di4so143362682wid.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:20:06 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id yz6si26512813wjc.31.2015.05.12.02.20.04
        for <linux-mm@kvack.org>;
        Tue, 12 May 2015 02:20:05 -0700 (PDT)
Date: Tue, 12 May 2015 12:19:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4 1/3] mm/thp: Split out pmd collpase flush into a
 separate functions
Message-ID: <20150512091951.GA18365@node.dhcp.inet.fi>
References: <1431410914-21102-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431410914-21102-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 12, 2015 at 11:38:32AM +0530, Aneesh Kumar K.V wrote:
> Architectures like ppc64 [1] need to do special things while clearing
> pmd before a collapse. For them this operation is largely different
> from a normal hugepage pte clear. Hence add a separate function
> to clear pmd before collapse. After this patch pmdp_* functions
> operate only on hugepage pte, and not on regular pmd_t values
> pointing to page table.
> 
> [1] ppc64 needs to invalidate all the normal page pte mappings we
> already have inserted in the hardware hash page table. But before
> doing that we need to make sure there are no parallel hash page
> table insert going on. So we need to do a kick_all_cpus_sync()
> before flushing the older hash table entries. By moving this to
> a separate function we capture these details and mention how it
> is different from a hugepage pte clear.
> 
> This patch is a cleanup and only does code movement for clarity.
> There should not be any change in functionality.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

For the patchset:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
