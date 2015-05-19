Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 41CCD6B00EA
	for <linux-mm@kvack.org>; Tue, 19 May 2015 18:21:00 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so42873633pdb.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 15:21:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hx10si999257pbc.131.2015.05.19.15.20.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 15:20:59 -0700 (PDT)
Date: Tue, 19 May 2015 15:20:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 0/3] THP related cleanups
Message-Id: <20150519152057.c183197e9bac117d4a179f80@linux-foundation.org>
In-Reply-To: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, 15 May 2015 21:12:27 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Changes from V4:
> * Folded patches in -mm
>   mm-thp-split-out-pmd-collpase-flush-into-a-separate-functions-fix.patch
>   mm-thp-split-out-pmd-collpase-flush-into-a-separate-functions-fix-2.patch
>   mm-clarify-that-the-function-operateds-on-hugepage-pte-fix.patch
> * Fix VM_BUG_ON on x86.
>  the default implementation of pmdp_collapse_flush used the hugepage variant
>  and hence can be called on pmd_t pointing to pgtable. This resulting in us
>  hitting VM_BUG_ON in pmdp_clear_flush. Update powerpc/mm: Use generic version of pmdp_clear_flush
>  to handle this.
> 
> 
> NOTE: Can we get this tested on s390 ?

fwiw, I build tested s390 allmodconfig in mm/ and arch/s390, no issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
