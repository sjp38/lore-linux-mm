Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2223C6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 13:21:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a10-v6so83062lff.9
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:21:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19-v6sor679374lfb.93.2018.06.20.10.21.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 10:21:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180620172046.GA27894@jordon-HP-15-Notebook-PC>
References: <20180620172046.GA27894@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 20 Jun 2018 22:51:49 +0530
Message-ID: <CAFqt6zYyE+Bm90CckQvJwfW85Hj2SN-Z6J6DidpgHu3h98Sgfg@mail.gmail.com>
Subject: Re: [PATCH] include: dax: new-return-type-vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Jun 20, 2018 at 10:50 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> Use new return type vm_fault_t for fault handler. For now,
> this is just documenting that the function returns a VM_FAULT
> value rather than an errno. Once all instances are converted,
> vm_fault_t will become a distinct type.
>
> commit 1c8f422059ae ("mm: change return type to vm_fault_t")
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> ---
>  include/linux/dax.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 7fddea8..11852d2 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -122,7 +122,7 @@ size_t dax_copy_from_iter(struct dax_device *dax_dev, pgoff_t pgoff, void *addr,
>
>  ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
>                 const struct iomap_ops *ops);
> -int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
> +vm_fault_t dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
>                     pfn_t *pfnp, int *errp, const struct iomap_ops *ops);
>  vm_fault_t dax_finish_sync_fault(struct vm_fault *vmf,
>                 enum page_entry_size pe_size, pfn_t pfn);
> --
> 1.9.1
>

Matthew/ Andrew,

As part of
commit ab77dab46210 ("fs/dax.c: use new return type vm_fault_t")
I missed this change which leads to compilation error.
Sorry about it.

This patch need to be in 4.18-rc-2/x on priority.
