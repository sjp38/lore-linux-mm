Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A31AD6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 16:05:26 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so754286pde.8
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:05:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qb4si1879390pdb.40.2014.10.01.13.05.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 13:05:25 -0700 (PDT)
Date: Wed, 1 Oct 2014 13:05:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: generalize VM_BUG_ON() macros
Message-Id: <20141001130523.d7cf46e735089d681194e8e6@linux-foundation.org>
In-Reply-To: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  1 Oct 2014 14:31:59 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> This patch makes VM_BUG_ON() to accept one to three arguments after the
> condition. Any of these arguments can be page, vma or mm. VM_BUG_ON()
> will dump info about the argument using appropriate dump_* function.
> 
> It's intended to replace separate VM_BUG_ON_PAGE(), VM_BUG_ON_VMA(),
> VM_BUG_ON_MM() and allows additional use-cases like:
> 
>   VM_BUG_ON(cond, vma, page);
>   VM_BUG_ON(cond, vma, src_page, dst_page);
>   VM_BUG_ON(cond, mm, src_vma, dst_vma);
>   ...

I can't say I'm a fan of this.  We don't do this sort of thing anywhere
else in the kernel and passing different types to the same thing in
different places is unusual and exceptional.  We gain very little from
this so why bother?

Adding new printk(%p) thingies for vmas and pages would be more
consistent but still of dubious value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
