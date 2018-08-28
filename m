Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 206FB6B4744
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 14:00:21 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id g16-v6so430216lfl.19
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 11:00:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p24-v6sor444080ljg.70.2018.08.28.11.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 11:00:19 -0700 (PDT)
MIME-Version: 1.0
References: <20180828174952.GA29229@jordon-HP-15-Notebook-PC>
In-Reply-To: <20180828174952.GA29229@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 28 Aug 2018 23:33:09 +0530
Message-ID: <CAFqt6zaDm-ashgujTicR1zcdkoPc=-VzopiTV3+hcin==t_o4g@mail.gmail.com>
Subject: Re: [PATCH] mm: Conveted to use vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, mgorman@techsingularity.net, ak@linux.intel.com, tim.c.chen@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Aug 28, 2018 at 11:18 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> As part of vm_fault_t conversion filemap_page_mkwrite()
> for NOMMU case was missed. Now converted.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

cc: Matthew Wilcox <willy@infradead.org>

> ---
>  mm/filemap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 52517f2..de6fed2 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2748,9 +2748,9 @@ int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
>         return generic_file_mmap(file, vma);
>  }
>  #else
> -int filemap_page_mkwrite(struct vm_fault *vmf)
> +vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf)
>  {
> -       return -ENOSYS;
> +       return VM_FAULT_SIGBUS;
>  }
>  int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
>  {
> --
> 1.9.1
>
