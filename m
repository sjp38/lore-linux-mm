Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8828E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 01:32:12 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so15855301pgr.15
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:32:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3si15655585plo.217.2018.12.18.22.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 22:32:10 -0800 (PST)
Date: Tue, 18 Dec 2018 22:31:50 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V4 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for
 hugetlb mprotect RW upgrade
Message-ID: <20181219063150.GA23418@infradead.org>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
 <20181218094137.13732-6-aneesh.kumar@linux.ibm.com>
 <20181218172236.GC22729@infradead.org>
 <87r2eefbhi.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r2eefbhi.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, Dec 19, 2018 at 08:50:57AM +0530, Aneesh Kumar K.V wrote:
> That was done considering that ptep_modify_prot_start/commit was defined
> in asm-generic/pgtable.h. I was trying to make sure I didn't break
> anything with the patch. Also s390 do have that EXPORT_SYMBOL() for the
> same. hugetlb just inherited that.
> 
> If you feel strongly about it, I can drop the EXPORT_SYMBOL().

Yes.  And we should probably remove the s390 as well as it isn't used
either.
