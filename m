Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id C2C826B00CB
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 08:55:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 12 Sep 2012 22:53:42 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8CCk0F311403376
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:46:00 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8CCtGXr016568
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:55:16 +1000
Message-ID: <50508632.9090003@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2012 20:55:14 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] thp: tidy and fix khugepaged_prealloc_page
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

There has a bug in khugepaged_prealloc_page, the page-alloc
indicator is not reset if the previous page request is failed,
then it will trigger the VM_BUG_ON in khugepaged_alloc_page.
It is fixed by the first patch which need not be back port for
it was introduced by recent commit. (sorry for that)

As Hugh pointed out, this are some ugly portions:
- releasing mmap_sem lock is hidden in khugepaged_alloc_page
- page is freed in khugepaged_prealloc_page
The later two patches try to fix these issues.

Hugh,

If any point i missed, please let me know, and sorry to waste
your time on my broken patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
