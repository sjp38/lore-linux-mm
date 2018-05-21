Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF7EA6B0005
	for <linux-mm@kvack.org>; Mon, 21 May 2018 17:19:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 89-v6so10802524plc.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 14:19:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 61-v6sor6047564plc.126.2018.05.21.14.19.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 14:19:34 -0700 (PDT)
Date: Mon, 21 May 2018 14:19:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/THP: use hugepage_vma_check() in
 khugepaged_enter_vma_merge()
In-Reply-To: <20180521193853.3089484-1-songliubraving@fb.com>
Message-ID: <alpine.DEB.2.21.1805211419210.41872@chino.kir.corp.google.com>
References: <20180521193853.3089484-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, 21 May 2018, Song Liu wrote:

> khugepaged_enter_vma_merge() is using a different approach to check
> whether a vma is valid for khugepaged_enter():
> 
>     if (!vma->anon_vma)
>             /*
>              * Not yet faulted in so we will register later in the
>              * page fault if needed.
>              */
>             return 0;
>     if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
>             /* khugepaged not yet working on file or special mappings */
>             return 0;
> 
> This check has some problems. One of the obvious problems is that
> it doesn't check shmem_file(), so that vma backed with shmem files
> will not call khugepaged_enter().
> 
> This patch fixes these problems by reusing hugepage_vma_check() in
> khugepaged_enter_vma_merge().
> 
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: David Rientjes <rientjes@google.com>
