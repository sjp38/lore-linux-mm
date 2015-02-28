Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E97D76B0032
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 01:47:18 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so28407732pab.1
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 22:47:18 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id q15si8100020pdl.247.2015.02.27.22.47.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 22:47:18 -0800 (PST)
Received: by pdbfp1 with SMTP id fp1so26198063pdb.9
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 22:47:17 -0800 (PST)
Date: Sat, 28 Feb 2015 14:46:47 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: [RFC] Strange do_munmap in mmap_region
Message-ID: <20150228064647.GA9550@udknight.ahead-top.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, yinghai@kernel.org.ahead-top.com, akpm@linux-foundation.org

Hi Mel Gorman and all.

I have read do_mmap_pgoff and mmap_region more than one hour,
but still can't catch sense about below code in mmap_region:

"
        /* Clear old maps */
        error = -ENOMEM;
munmap_back:
        if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
                if (do_munmap(mm, addr, len))
                        return -ENOMEM;
                goto munmap_back;
        }
"

How can we just do_munmap overlapping vma without check its vm_flags
and new vma's vm_flags? I must miss some important things, but I can't
figure out.

You give below comment about the code in "understand the linux memory manager":)

"
If a VMA was found and it is part of the new mmapping, this removes the
 old mmapping because the new one will cover both 
"

But if new mmapping has different vm_flags or others' property, how
can we just say the new one will cover both?

I appreicate any clue and explanation about this headache question.

Thanks.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
