Received: by py-out-1112.google.com with SMTP id c59so778800pyc
        for <Linux-MM@kvack.org>; Thu, 28 Sep 2006 07:25:02 -0700 (PDT)
Date: Thu, 28 Sep 2006 23:24:59 +0900
Subject: Shared and/or locked anonymous pages
From: girish <girishvg@gmail.com>
Message-ID: <C1420A4B.7BAF%girishvg@gmail.com>
Mime-version: 1.0
Content-type: text/plain;
	charset="US-ASCII"
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <Linux-MM@kvack.org>
Cc: girish <girishvg@gmail.com>
List-ID: <linux-mm.kvack.org>

Hello.

I have a *very* basic question!

Is it legal to provide anonymous mapping on shared and/or locked pages in
user space?

I am trying to implement a Special VM area in the user space, which will map
the kernel I/O space. A straightforward & simple approach would be to go
through /dev/mem or /dev/kmem device. But I am trying to implement one
system call which will do the job of anonymous mapping.

Here is an algorithm I have in mind -
        struct vm_area_struct *vma = create_anon (current->mm, addr, size)
        struct page *pg = alloc_pages (nrpages, locked | shared)
        vma->vm_pgoff = page_to_pfn (pg)
        remap_pfn_range (vma... vma->vm_pgoff... Size... locked | shared)

Is it possible? If it is not - what is the reason?

Thanks.
Girish.
      


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
