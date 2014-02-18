Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 91FD96B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:12:08 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so16670448pde.6
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:12:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id x3si19650899pbk.263.2014.02.18.14.12.07
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 14:12:07 -0800 (PST)
Subject: Patch "mm: fix process accidentally killed by mce because of huge page migration" has been added to the 3.10-stable tree
From: <gregkh@linuxfoundation.org>
Date: Tue, 18 Feb 2014 14:13:32 -0800
In-Reply-To: <52FD807F.5010105@huawei.com>
Message-ID: <13927616123106@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi@huawei.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, lizefan@huawei.com, n-horiguchi@ah.jp.nec.com, stable@vger.kernel.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    mm: fix process accidentally killed by mce because of huge page migration

to the 3.10-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     mm-fix-process-accidentally-killed-by-mce-because-of-huge-page-migration.patch
and it can be found in the queue-3.10 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
