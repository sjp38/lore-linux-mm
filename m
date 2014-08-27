Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0303F6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:56:17 -0400 (EDT)
Received: by mail-oi0-f48.google.com with SMTP id v63so2627098oia.7
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 02:56:17 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s4si6320290oek.83.2014.08.27.02.56.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 02:56:17 -0700 (PDT)
Date: Wed, 27 Aug 2014 12:56:13 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [next:master 2131/2422] kernel/sys.c:1888 prctl_set_mm_map() warn:
 maybe return -EFAULT instead of the bytes remaining?
Message-ID: <20140827095613.GN5100@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>


tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   d05446ae2128064a4bb8f74c84f6901ffb5c94bc
commit: 802d335c0f7f1a1867bf59814c55970a71b10413 [2131/2422] prctl: PR_SET_MM -- introduce PR_SET_MM_MAP operation

kernel/sys.c:1888 prctl_set_mm_map() warn: maybe return -EFAULT instead of the bytes remaining?

git remote add next git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git remote update next
git checkout 802d335c0f7f1a1867bf59814c55970a71b10413
vim +1888 kernel/sys.c

802d335c Cyrill Gorcunov 2014-08-26  1872  
802d335c Cyrill Gorcunov 2014-08-26  1873  	mm->start_code	= prctl_map.start_code;
802d335c Cyrill Gorcunov 2014-08-26  1874  	mm->end_code	= prctl_map.end_code;
802d335c Cyrill Gorcunov 2014-08-26  1875  	mm->start_data	= prctl_map.start_data;
802d335c Cyrill Gorcunov 2014-08-26  1876  	mm->end_data	= prctl_map.end_data;
802d335c Cyrill Gorcunov 2014-08-26  1877  	mm->start_brk	= prctl_map.start_brk;
802d335c Cyrill Gorcunov 2014-08-26  1878  	mm->brk		= prctl_map.brk;
802d335c Cyrill Gorcunov 2014-08-26  1879  	mm->start_stack	= prctl_map.start_stack;
802d335c Cyrill Gorcunov 2014-08-26  1880  	mm->arg_start	= prctl_map.arg_start;
802d335c Cyrill Gorcunov 2014-08-26  1881  	mm->arg_end	= prctl_map.arg_end;
802d335c Cyrill Gorcunov 2014-08-26  1882  	mm->env_start	= prctl_map.env_start;
802d335c Cyrill Gorcunov 2014-08-26  1883  	mm->env_end	= prctl_map.env_end;
802d335c Cyrill Gorcunov 2014-08-26  1884  
802d335c Cyrill Gorcunov 2014-08-26  1885  	error = 0;
802d335c Cyrill Gorcunov 2014-08-26  1886  out:
802d335c Cyrill Gorcunov 2014-08-26  1887  	up_read(&mm->mmap_sem);
802d335c Cyrill Gorcunov 2014-08-26 @1888  	return error;
802d335c Cyrill Gorcunov 2014-08-26  1889  }
802d335c Cyrill Gorcunov 2014-08-26  1890  #endif /* CONFIG_CHECKPOINT_RESTORE */
802d335c Cyrill Gorcunov 2014-08-26  1891  
028ee4be Cyrill Gorcunov 2012-01-12  1892  static int prctl_set_mm(int opt, unsigned long addr,
028ee4be Cyrill Gorcunov 2012-01-12  1893  			unsigned long arg4, unsigned long arg5)
028ee4be Cyrill Gorcunov 2012-01-12  1894  {
028ee4be Cyrill Gorcunov 2012-01-12  1895  	struct mm_struct *mm = current->mm;
fe8c7f5c Cyrill Gorcunov 2012-05-31  1896  	struct vm_area_struct *vma;

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
