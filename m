Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AF3B56B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 10:11:39 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so2491188pad.17
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 07:11:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zl8si4065206pac.135.2014.10.02.07.11.37
        for <linux-mm@kvack.org>;
        Thu, 02 Oct 2014 07:11:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20141001130523.d7cf46e735089d681194e8e6@linux-foundation.org>
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20141001130523.d7cf46e735089d681194e8e6@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: generalize VM_BUG_ON() macros
Content-Transfer-Encoding: 7bit
Message-Id: <20141002141133.B56A6E00A3@blue.fi.intel.com>
Date: Thu,  2 Oct 2014 17:11:33 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> On Wed,  1 Oct 2014 14:31:59 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > This patch makes VM_BUG_ON() to accept one to three arguments after the
> > condition. Any of these arguments can be page, vma or mm. VM_BUG_ON()
> > will dump info about the argument using appropriate dump_* function.
> > 
> > It's intended to replace separate VM_BUG_ON_PAGE(), VM_BUG_ON_VMA(),
> > VM_BUG_ON_MM() and allows additional use-cases like:
> > 
> >   VM_BUG_ON(cond, vma, page);
> >   VM_BUG_ON(cond, vma, src_page, dst_page);
> >   VM_BUG_ON(cond, mm, src_vma, dst_vma);
> >   ...
> 
> I can't say I'm a fan of this.  We don't do this sort of thing anywhere
> else in the kernel and passing different types to the same thing in
> different places is unusual and exceptional.  We gain very little from
> this so why bother?

We had bug like this: lkml.kernel.org/r/53F487EB.7070703@oracle.com where
it's useful to see more than one structure dumped: vma + page in this
case.

We can keep inventing new macros: VM_BUG_ON_PAGE_AND_VM() for the case.
But why not have one to rule them all? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
