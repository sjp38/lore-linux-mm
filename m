Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A895E6B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 18:10:02 -0400 (EDT)
Received: by patj18 with SMTP id j18so128277689pat.2
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 15:10:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h13si13651921pdf.62.2015.04.03.15.10.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 15:10:01 -0700 (PDT)
Date: Fri, 3 Apr 2015 15:10:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory: print also a_ops->readpage in print_bad_pte
Message-Id: <20150403151000.b51caa3f692358610fc1ca5d@linux-foundation.org>
In-Reply-To: <20150403171818.22742.92919.stgit@buzz>
References: <20150403171818.22742.92919.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org

On Fri, 03 Apr 2015 20:18:18 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> A lot of filesystems use generic_file_mmap() and filemap_fault(),
> f_op->mmap and vm_ops->fault aren't enough to identify filesystem.
> 
> This prints file name, vm_ops->fault, f_op->mmap and a_ops->readpage
> (which is almost always implemented and filesystem-specific).
> 
> Example:
> 
> [   23.676410] BUG: Bad page map in process sh  pte:1b7e6025 pmd:19bbd067
> [   23.676887] page:ffffea00006df980 count:4 mapcount:1 mapping:ffff8800196426c0 index:0x97
> [   23.677481] flags: 0x10000000000000c(referenced|uptodate)
> [   23.677896] page dumped because: bad pte
> [   23.678205] addr:00007f52fcb17000 vm_flags:00000075 anon_vma:          (null) mapping:ffff8800196426c0 index:97
> [   23.678922] file:libc-2.19.so fault:filemap_fault mmap:generic_file_readonly_mmap readpage:v9fs_vfs_readpage

Is that why we print these out?  Just to identify the fs type?

There's always vma->vm_file->f_inode->i_sb->s_magic ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
