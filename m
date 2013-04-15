Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4D41E6B0006
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 14:09:55 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id j1so4605676oag.7
        for <linux-mm@kvack.org>; Mon, 15 Apr 2013 11:09:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1366030138-71292-2-git-send-email-huawei.libin@huawei.com>
References: <1366030138-71292-1-git-send-email-huawei.libin@huawei.com> <1366030138-71292-2-git-send-email-huawei.libin@huawei.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 15 Apr 2013 12:09:34 -0600
Message-ID: <CAErSpo6zpqkVZA-tbb8zXd9=WQ71JUCNPwDzx=009=Kv8tHgGw@mail.gmail.com>
Subject: Re: [PATCH 2/6] PCI: use vma_pages() to replace (vm_end - vm_start)
 >> PAGE_SHIFT
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Airlie <airlied@linux.ie>, "Hans J. Koch" <hjk@hansjkoch.de>, Petr Vandrovec <petr@vandrovec.name>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Thomas Hellstrom <thellstrom@vmware.com>, Dave Airlie <airlied@redhat.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jiri Kosina <jkosina@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Yijing Wang <wangyijing@huawei.com>

On Mon, Apr 15, 2013 at 6:48 AM, Libin <huawei.libin@huawei.com> wrote:
> (*->vm_end - *->vm_start) >> PAGE_SHIFT operation is implemented
> as a inline funcion vma_pages() in linux/mm.h, so using it.
>
> Signed-off-by: Libin <huawei.libin@huawei.com>

Applied to my pci/misc branch for v3.10, thanks!

Bjorn

> ---
>  drivers/pci/pci-sysfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
> index 9c6e9bb..5b4a9d9 100644
> --- a/drivers/pci/pci-sysfs.c
> +++ b/drivers/pci/pci-sysfs.c
> @@ -897,7 +897,7 @@ int pci_mmap_fits(struct pci_dev *pdev, int resno, struct vm_area_struct *vma,
>
>         if (pci_resource_len(pdev, resno) == 0)
>                 return 0;
> -       nr = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
> +       nr = vma_pages(vma);
>         start = vma->vm_pgoff;
>         size = ((pci_resource_len(pdev, resno) - 1) >> PAGE_SHIFT) + 1;
>         pci_start = (mmap_api == PCI_MMAP_PROCFS) ?
> --
> 1.8.2.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
