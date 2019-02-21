Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E752FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 03:14:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 697A42086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 03:14:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WcwlfgRh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 697A42086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE7468E0059; Wed, 20 Feb 2019 22:14:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6FE38E0002; Wed, 20 Feb 2019 22:14:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5F7B8E0059; Wed, 20 Feb 2019 22:14:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 333048E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 22:14:32 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id v4so2058707ljc.21
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:14:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aM8TRNuzJ3VArCdJFkaUZ5ab2p1dPmeFOeRw2H22Q7c=;
        b=oanDAm8Qcj9BthhnC5Vf07klh1A5zu/lwI4dZnzzEsByKAo8pKw3wAN5ChdvBFGjhu
         zLEpEhPKi5ttnSobOzAmGdDGx3o9r/ZJKVxnwCDhwaZDIxOFc6uVJSV5t5shWybOhhfT
         eorV8wOoFMY3rXQW+ZybZAxesWV3KtTGdbZrk5vnzwkF7qo/z0QiqHlb79rV9C3GLoNt
         KHmroiRsGEzLW14qAakqt5Dhljc0g2aoL6qvZ/OyseTqWPQprneu7FjL5a48SQd4eRDH
         vBgsnY2hjSgUn1P4sqvtARnmIljf+WM0BXQ7nLCTH0vmRXLkamnz8dlDQw/HzMplx9ci
         v3JA==
X-Gm-Message-State: AHQUAuafMHC46gcI2lXksJA1aOR2vSmkvF5fP19lhc48eYCoWSViL5cn
	kRUCyHuuDRP+G5beAHdu73dPVwkHHAJCbgH/A9QGZla2U1Nr6fF9Qure1Syq43yvGXXz8ZP5v97
	OjketjMEL3zKla9yIsr9eIWzjld1jh10zTH+kKEjBwkmoNNWtNwHsBLiPb53DldGTm4fwAwbIEB
	5pKOBCL/+WOynfQ7/FVTmay5+La4B6VMP5+BVOzsO0fSGcGZtZEl+3JhgE+CJRmYU+LJRDQoNSR
	99KbiqEOK386/nFIPlbNH6I8CjKnSRNGjv1BNPTgai56FuzuNEpw52Eu1vv7ogWwunGhSQ255ve
	gGkTgpths5UNJLZKJ+qxBXDRmu9RyZYjL8mGPnNABJjke5mk/343/n/9nozWUVhHEA9r2Rampz/
	s
X-Received: by 2002:a2e:898e:: with SMTP id c14mr15450538lji.115.1550718871256;
        Wed, 20 Feb 2019 19:14:31 -0800 (PST)
X-Received: by 2002:a2e:898e:: with SMTP id c14mr15450447lji.115.1550718868320;
        Wed, 20 Feb 2019 19:14:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550718868; cv=none;
        d=google.com; s=arc-20160816;
        b=ZT74jrI2RQGJQ0tXOYEVcHT9NHNE2P5hovuu9rHSn91tqeC2gSpxQtzmhtIlcCfGMC
         jtakKeDBSMxWtqO3rBIzs10YEhTnKN8S8FgAGDPDDtKEhSN8C3s2SzR8Dp/17czulQ6F
         9yRNh0c+JoKGGZdeNGQhpmq3hTla6FNfe9C1+HQEJYP0RboNun0fd7jB0LrGaoqqpjAN
         jSoitkcNWNyfhC5Q8ZumNB8a9UJiUApj5/O5FcMN6UkdPwRVc2lJw0Y7lw9WM3x+RgWH
         ROEjuDlEVDNP5c0niHSnhHLJz1AoKV+ftbzpgqV1Ub7yup/LzF/94z4VRN9OxDOvsfY0
         E+RQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aM8TRNuzJ3VArCdJFkaUZ5ab2p1dPmeFOeRw2H22Q7c=;
        b=jB7FDWOWhVofxAn0uya0/tQrr3ksXEY/aGU6s3zpxLZZexxWwvKDEPXxa02voMwIpP
         fZG3p6htajeaohUfXVyc8cBCQwhvfY91rziAqRwtA6QoPaxzOKHIlMCS7zBGwqm6jozt
         kv6NvZGDTzRLTuYdeSMhA4WsXxo8XtZA5OYEok0QjK4L4FVyk8cOjZJDQfNfXm+cnq2h
         eXhITg2eVzrY+HLEJGJ+hM0/X1H8L7aqCKtcbtTyVuYXtzjDpZ3RSa1UZC54FhjUkNNB
         RE5VAJxRQ21ZuIXvgvKcd9603YQWqjfbp2oYhl8WHAWvGoRZoaUW3RIxcIA5S5vW0b2Z
         mqZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WcwlfgRh;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22-v6sor12803773ljd.6.2019.02.20.19.14.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 19:14:28 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WcwlfgRh;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aM8TRNuzJ3VArCdJFkaUZ5ab2p1dPmeFOeRw2H22Q7c=;
        b=WcwlfgRhlJX1FHSVuUNAjMNbxv516BlWc0YQ6gx9Of/X0ZIBACOBZaTrLl90Vt+KTI
         QB4Xt1hK/+0oPG+7ynTzs67Q6bNQYZnWMinifbQU4ckfmF7morKBqxOOWVbDPh4GpKBD
         XMr0kG77EzNQVpJ8PM4aL/rE/72ZV4T8O7LaeIl4NcsRUBjQepl8rl2b3R+A71pPxOSa
         QZBobVauhwiqBAVOAr35+aIRFk25nmnRJsQHJeQhfDKYlG0+7xslTtPB6ovkcMCVIN/9
         zzste2WrEymLX+kEoDfPJkUdBGbOC5SDF51tMUhp2br7Cqqyvt3rCDyt0h/aenvvpyLc
         gz+Q==
X-Google-Smtp-Source: AHgI3IawBMq2msEgV4CUI9btMrNUwexvQY3i20ysOkV8Y61F8PlZgpxIGJBqkaqt9zhBoRGEX3DTV8t7liR4VjSyifQ=
X-Received: by 2002:a2e:9916:: with SMTP id v22mr5322502lji.68.1550718867500;
 Wed, 20 Feb 2019 19:14:27 -0800 (PST)
MIME-Version: 1.0
References: <20190220053040.10831-1-ira.weiny@intel.com> <20190220053040.10831-4-ira.weiny@intel.com>
In-Reply-To: <20190220053040.10831-4-ira.weiny@intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 21 Feb 2019 08:48:41 +0530
Message-ID: <CAFqt6zYvkhKw3GExRQB2e_c16KQqrKT=GoiqErA06txUQa2bMQ@mail.gmail.com>
Subject: Re: [RESEND PATCH 3/7] mm/gup: Change GUP fast to use flags rather
 than a write 'bool'
To: ira.weiny@intel.com
Cc: John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, 
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, kvm-ppc@vger.kernel.org, 
	kvm@vger.kernel.org, linux-fpga@vger.kernel.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, virtualization@lists.linux-foundation.org, 
	netdev@vger.kernel.org, linux-fbdev@vger.kernel.org, 
	xen-devel@lists.xenproject.org, devel@lists.orangefs.org, 
	ceph-devel@vger.kernel.org, rds-devel@oss.oracle.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ira,

On Wed, Feb 20, 2019 at 11:01 AM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> To facilitate additional options to get_user_pages_fast() change the
> singular write parameter to be gup_flags.
>
> This patch does not change any functionality.  New functionality will
> follow in subsequent patches.
>
> Some of the get_user_pages_fast() call sites were unchanged because they
> already passed FOLL_WRITE or 0 for the write parameter.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  arch/mips/mm/gup.c                         | 11 ++++++-----
>  arch/powerpc/kvm/book3s_64_mmu_hv.c        |  4 ++--
>  arch/powerpc/kvm/e500_mmu.c                |  2 +-
>  arch/powerpc/mm/mmu_context_iommu.c        |  4 ++--
>  arch/s390/kvm/interrupt.c                  |  2 +-
>  arch/s390/mm/gup.c                         | 12 ++++++------
>  arch/sh/mm/gup.c                           | 11 ++++++-----
>  arch/sparc/mm/gup.c                        |  9 +++++----
>  arch/x86/kvm/paging_tmpl.h                 |  2 +-
>  arch/x86/kvm/svm.c                         |  2 +-
>  drivers/fpga/dfl-afu-dma-region.c          |  2 +-
>  drivers/gpu/drm/via/via_dmablit.c          |  3 ++-
>  drivers/infiniband/hw/hfi1/user_pages.c    |  3 ++-
>  drivers/misc/genwqe/card_utils.c           |  2 +-
>  drivers/misc/vmw_vmci/vmci_host.c          |  2 +-
>  drivers/misc/vmw_vmci/vmci_queue_pair.c    |  6 ++++--
>  drivers/platform/goldfish/goldfish_pipe.c  |  3 ++-
>  drivers/rapidio/devices/rio_mport_cdev.c   |  4 +++-
>  drivers/sbus/char/oradax.c                 |  2 +-
>  drivers/scsi/st.c                          |  3 ++-
>  drivers/staging/gasket/gasket_page_table.c |  4 ++--
>  drivers/tee/tee_shm.c                      |  2 +-
>  drivers/vfio/vfio_iommu_spapr_tce.c        |  3 ++-
>  drivers/vhost/vhost.c                      |  2 +-
>  drivers/video/fbdev/pvr2fb.c               |  2 +-
>  drivers/virt/fsl_hypervisor.c              |  2 +-
>  drivers/xen/gntdev.c                       |  2 +-
>  fs/orangefs/orangefs-bufmap.c              |  2 +-
>  include/linux/mm.h                         |  4 ++--
>  kernel/futex.c                             |  2 +-
>  lib/iov_iter.c                             |  7 +++++--
>  mm/gup.c                                   | 10 +++++-----
>  mm/util.c                                  |  8 ++++----
>  net/ceph/pagevec.c                         |  2 +-
>  net/rds/info.c                             |  2 +-
>  net/rds/rdma.c                             |  3 ++-
>  36 files changed, 81 insertions(+), 65 deletions(-)
>
> diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
> index 0d14e0d8eacf..4c2b4483683c 100644
> --- a/arch/mips/mm/gup.c
> +++ b/arch/mips/mm/gup.c
> @@ -235,7 +235,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
>   * @nr_pages:  number of pages from start to pin
> - * @write:     whether pages will be written to
> + * @gup_flags: flags modifying pin behaviour
>   * @pages:     array that receives pointers to the pages pinned.
>   *             Should be at least nr_pages long.
>   *
> @@ -247,8 +247,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
>   * were pinned, returns -errno.
>   */
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages)
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages)
>  {
>         struct mm_struct *mm = current->mm;
>         unsigned long addr, len, end;
> @@ -273,7 +273,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>                 next = pgd_addr_end(addr, end);
>                 if (pgd_none(pgd))
>                         goto slow;
> -               if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
> +               if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
> +                                  pages, &nr))
>                         goto slow;
>         } while (pgdp++, addr = next, addr != end);
>         local_irq_enable();
> @@ -289,7 +290,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>         pages += nr;
>
>         ret = get_user_pages_unlocked(start, (end - start) >> PAGE_SHIFT,
> -                                     pages, write ? FOLL_WRITE : 0);
> +                                     pages, gup_flags);
>
>         /* Have to be a bit careful with return values */
>         if (nr > 0) {
> diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
> index bd2dcfbf00cd..8fcb0a921e46 100644
> --- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
> +++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
> @@ -582,7 +582,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
>         /* If writing != 0, then the HPTE must allow writing, if we get here */
>         write_ok = writing;
>         hva = gfn_to_hva_memslot(memslot, gfn);
> -       npages = get_user_pages_fast(hva, 1, writing, pages);
> +       npages = get_user_pages_fast(hva, 1, writing ? FOLL_WRITE : 0, pages);

Just requesting for opinion,
* writing ? FOLL_WRITE : 0 * is used in many places. How about placing it in a
macro/ inline ?

>         if (npages < 1) {
>                 /* Check if it's an I/O mapping */
>                 down_read(&current->mm->mmap_sem);
> @@ -1175,7 +1175,7 @@ void *kvmppc_pin_guest_page(struct kvm *kvm, unsigned long gpa,
>         if (!memslot || (memslot->flags & KVM_MEMSLOT_INVALID))
>                 goto err;
>         hva = gfn_to_hva_memslot(memslot, gfn);
> -       npages = get_user_pages_fast(hva, 1, 1, pages);
> +       npages = get_user_pages_fast(hva, 1, FOLL_WRITE, pages);
>         if (npages < 1)
>                 goto err;
>         page = pages[0];
> diff --git a/arch/powerpc/kvm/e500_mmu.c b/arch/powerpc/kvm/e500_mmu.c
> index 24296f4cadc6..e0af53fd78c5 100644
> --- a/arch/powerpc/kvm/e500_mmu.c
> +++ b/arch/powerpc/kvm/e500_mmu.c
> @@ -783,7 +783,7 @@ int kvm_vcpu_ioctl_config_tlb(struct kvm_vcpu *vcpu,
>         if (!pages)
>                 return -ENOMEM;
>
> -       ret = get_user_pages_fast(cfg->array, num_pages, 1, pages);
> +       ret = get_user_pages_fast(cfg->array, num_pages, FOLL_WRITE, pages);
>         if (ret < 0)
>                 goto free_pages;
>
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index a712a650a8b6..acb0990c8364 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -190,7 +190,7 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
>         for (i = 0; i < entries; ++i) {
>                 cur_ua = ua + (i << PAGE_SHIFT);
>                 if (1 != get_user_pages_fast(cur_ua,
> -                                       1/* pages */, 1/* iswrite */, &page)) {
> +                                       1/* pages */, FOLL_WRITE, &page)) {
>                         ret = -EFAULT;
>                         for (j = 0; j < i; ++j)
>                                 put_page(pfn_to_page(mem->hpas[j] >>
> @@ -209,7 +209,7 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
>                         if (mm_iommu_move_page_from_cma(page))
>                                 goto populate;
>                         if (1 != get_user_pages_fast(cur_ua,
> -                                               1/* pages */, 1/* iswrite */,
> +                                               1/* pages */, FOLL_WRITE,
>                                                 &page)) {
>                                 ret = -EFAULT;
>                                 for (j = 0; j < i; ++j)
> diff --git a/arch/s390/kvm/interrupt.c b/arch/s390/kvm/interrupt.c
> index fcb55b02990e..69d9366b966c 100644
> --- a/arch/s390/kvm/interrupt.c
> +++ b/arch/s390/kvm/interrupt.c
> @@ -2278,7 +2278,7 @@ static int kvm_s390_adapter_map(struct kvm *kvm, unsigned int id, __u64 addr)
>                 ret = -EFAULT;
>                 goto out;
>         }
> -       ret = get_user_pages_fast(map->addr, 1, 1, &map->page);
> +       ret = get_user_pages_fast(map->addr, 1, FOLL_WRITE, &map->page);
>         if (ret < 0)
>                 goto out;
>         BUG_ON(ret != 1);
> diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
> index 2809d11c7a28..0a6faf3d9960 100644
> --- a/arch/s390/mm/gup.c
> +++ b/arch/s390/mm/gup.c
> @@ -265,7 +265,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
>   * @nr_pages:  number of pages from start to pin
> - * @write:     whether pages will be written to
> + * @gup_flags: flags modifying pin behaviour
>   * @pages:     array that receives pointers to the pages pinned.
>   *             Should be at least nr_pages long.
>   *
> @@ -277,22 +277,22 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
>   * were pinned, returns -errno.
>   */
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages)
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages)
>  {
>         int nr, ret;
>
>         might_sleep();
>         start &= PAGE_MASK;
> -       nr = __get_user_pages_fast(start, nr_pages, write, pages);
> +       nr = __get_user_pages_fast(start, nr_pages, gup_flags & FOLL_WRITE,
> +                                  pages);
>         if (nr == nr_pages)
>                 return nr;
>
>         /* Try to get the remaining pages with get_user_pages */
>         start += nr << PAGE_SHIFT;
>         pages += nr;
> -       ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
> -                                     write ? FOLL_WRITE : 0);
> +       ret = get_user_pages_unlocked(start, nr_pages - nr, pages, gup_flags);
>         /* Have to be a bit careful with return values */
>         if (nr > 0)
>                 ret = (ret < 0) ? nr : ret + nr;
> diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
> index 3e27f6d1f1ec..277c882f7489 100644
> --- a/arch/sh/mm/gup.c
> +++ b/arch/sh/mm/gup.c
> @@ -204,7 +204,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
>   * @nr_pages:  number of pages from start to pin
> - * @write:     whether pages will be written to
> + * @gup_flags: flags modifying pin behaviour
>   * @pages:     array that receives pointers to the pages pinned.
>   *             Should be at least nr_pages long.
>   *
> @@ -216,8 +216,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
>   * were pinned, returns -errno.
>   */
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages)
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages)
>  {
>         struct mm_struct *mm = current->mm;
>         unsigned long addr, len, end;
> @@ -241,7 +241,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>                 next = pgd_addr_end(addr, end);
>                 if (pgd_none(pgd))
>                         goto slow;
> -               if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
> +               if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
> +                                  pages, &nr))
>                         goto slow;
>         } while (pgdp++, addr = next, addr != end);
>         local_irq_enable();
> @@ -261,7 +262,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>
>                 ret = get_user_pages_unlocked(start,
>                         (end - start) >> PAGE_SHIFT, pages,
> -                       write ? FOLL_WRITE : 0);
> +                       gup_flags);
>
>                 /* Have to be a bit careful with return values */
>                 if (nr > 0) {
> diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
> index aee6dba83d0e..1e770a517d4a 100644
> --- a/arch/sparc/mm/gup.c
> +++ b/arch/sparc/mm/gup.c
> @@ -245,8 +245,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>         return nr;
>  }
>
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages)
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages)
>  {
>         struct mm_struct *mm = current->mm;
>         unsigned long addr, len, end;
> @@ -303,7 +303,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>                 next = pgd_addr_end(addr, end);
>                 if (pgd_none(pgd))
>                         goto slow;
> -               if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
> +               if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
> +                                  pages, &nr))
>                         goto slow;
>         } while (pgdp++, addr = next, addr != end);
>
> @@ -324,7 +325,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>
>                 ret = get_user_pages_unlocked(start,
>                         (end - start) >> PAGE_SHIFT, pages,
> -                       write ? FOLL_WRITE : 0);
> +                       gup_flags);
>
>                 /* Have to be a bit careful with return values */
>                 if (nr > 0) {
> diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> index 6bdca39829bc..08715034e315 100644
> --- a/arch/x86/kvm/paging_tmpl.h
> +++ b/arch/x86/kvm/paging_tmpl.h
> @@ -140,7 +140,7 @@ static int FNAME(cmpxchg_gpte)(struct kvm_vcpu *vcpu, struct kvm_mmu *mmu,
>         pt_element_t *table;
>         struct page *page;
>
> -       npages = get_user_pages_fast((unsigned long)ptep_user, 1, 1, &page);
> +       npages = get_user_pages_fast((unsigned long)ptep_user, 1, FOLL_WRITE, &page);
>         /* Check if the user is doing something meaningless. */
>         if (unlikely(npages != 1))
>                 return -EFAULT;
> diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
> index f13a3a24d360..173596a020cb 100644
> --- a/arch/x86/kvm/svm.c
> +++ b/arch/x86/kvm/svm.c
> @@ -1803,7 +1803,7 @@ static struct page **sev_pin_memory(struct kvm *kvm, unsigned long uaddr,
>                 return NULL;
>
>         /* Pin the user virtual address. */
> -       npinned = get_user_pages_fast(uaddr, npages, write ? FOLL_WRITE : 0, pages);
> +       npinned = get_user_pages_fast(uaddr, npages, FOLL_WRITE, pages);
>         if (npinned != npages) {
>                 pr_err("SEV: Failure locking %lu pages.\n", npages);
>                 goto err;
> diff --git a/drivers/fpga/dfl-afu-dma-region.c b/drivers/fpga/dfl-afu-dma-region.c
> index e18a786fc943..c438722bf4e1 100644
> --- a/drivers/fpga/dfl-afu-dma-region.c
> +++ b/drivers/fpga/dfl-afu-dma-region.c
> @@ -102,7 +102,7 @@ static int afu_dma_pin_pages(struct dfl_feature_platform_data *pdata,
>                 goto unlock_vm;
>         }
>
> -       pinned = get_user_pages_fast(region->user_addr, npages, 1,
> +       pinned = get_user_pages_fast(region->user_addr, npages, FOLL_WRITE,
>                                      region->pages);
>         if (pinned < 0) {
>                 ret = pinned;
> diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
> index 345bda4494e1..0c8b09602910 100644
> --- a/drivers/gpu/drm/via/via_dmablit.c
> +++ b/drivers/gpu/drm/via/via_dmablit.c
> @@ -239,7 +239,8 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
>         if (NULL == vsg->pages)
>                 return -ENOMEM;
>         ret = get_user_pages_fast((unsigned long)xfer->mem_addr,
> -                       vsg->num_pages, vsg->direction == DMA_FROM_DEVICE,
> +                       vsg->num_pages,
> +                       vsg->direction == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
>                         vsg->pages);
>         if (ret != vsg->num_pages) {
>                 if (ret < 0)
> diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
> index 24b592c6522e..78ccacaf97d0 100644
> --- a/drivers/infiniband/hw/hfi1/user_pages.c
> +++ b/drivers/infiniband/hw/hfi1/user_pages.c
> @@ -105,7 +105,8 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
>  {
>         int ret;
>
> -       ret = get_user_pages_fast(vaddr, npages, writable, pages);
> +       ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
> +                                 pages);
>         if (ret < 0)
>                 return ret;
>
> diff --git a/drivers/misc/genwqe/card_utils.c b/drivers/misc/genwqe/card_utils.c
> index 25265fd0fd6e..89cff9d1012b 100644
> --- a/drivers/misc/genwqe/card_utils.c
> +++ b/drivers/misc/genwqe/card_utils.c
> @@ -603,7 +603,7 @@ int genwqe_user_vmap(struct genwqe_dev *cd, struct dma_mapping *m, void *uaddr,
>         /* pin user pages in memory */
>         rc = get_user_pages_fast(data & PAGE_MASK, /* page aligned addr */
>                                  m->nr_pages,
> -                                m->write,              /* readable/writable */
> +                                m->write ? FOLL_WRITE : 0,     /* readable/writable */
>                                  m->page_list); /* ptrs to pages */
>         if (rc < 0)
>                 goto fail_get_user_pages;
> diff --git a/drivers/misc/vmw_vmci/vmci_host.c b/drivers/misc/vmw_vmci/vmci_host.c
> index 997f92543dd4..422d08da3244 100644
> --- a/drivers/misc/vmw_vmci/vmci_host.c
> +++ b/drivers/misc/vmw_vmci/vmci_host.c
> @@ -242,7 +242,7 @@ static int vmci_host_setup_notify(struct vmci_ctx *context,
>         /*
>          * Lock physical page backing a given user VA.
>          */
> -       retval = get_user_pages_fast(uva, 1, 1, &context->notify_page);
> +       retval = get_user_pages_fast(uva, 1, FOLL_WRITE, &context->notify_page);
>         if (retval != 1) {
>                 context->notify_page = NULL;
>                 return VMCI_ERROR_GENERIC;
> diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
> index 264f4ed8eef2..c5396ee32e51 100644
> --- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
> +++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
> @@ -666,7 +666,8 @@ static int qp_host_get_user_memory(u64 produce_uva,
>         int err = VMCI_SUCCESS;
>
>         retval = get_user_pages_fast((uintptr_t) produce_uva,
> -                                    produce_q->kernel_if->num_pages, 1,
> +                                    produce_q->kernel_if->num_pages,
> +                                    FOLL_WRITE,
>                                      produce_q->kernel_if->u.h.header_page);
>         if (retval < (int)produce_q->kernel_if->num_pages) {
>                 pr_debug("get_user_pages_fast(produce) failed (retval=%d)",
> @@ -678,7 +679,8 @@ static int qp_host_get_user_memory(u64 produce_uva,
>         }
>
>         retval = get_user_pages_fast((uintptr_t) consume_uva,
> -                                    consume_q->kernel_if->num_pages, 1,
> +                                    consume_q->kernel_if->num_pages,
> +                                    FOLL_WRITE,
>                                      consume_q->kernel_if->u.h.header_page);
>         if (retval < (int)consume_q->kernel_if->num_pages) {
>                 pr_debug("get_user_pages_fast(consume) failed (retval=%d)",
> diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
> index 321bc673c417..cef0133aa47a 100644
> --- a/drivers/platform/goldfish/goldfish_pipe.c
> +++ b/drivers/platform/goldfish/goldfish_pipe.c
> @@ -274,7 +274,8 @@ static int pin_user_pages(unsigned long first_page,
>                 *iter_last_page_size = last_page_size;
>         }
>
> -       ret = get_user_pages_fast(first_page, requested_pages, !is_write,
> +       ret = get_user_pages_fast(first_page, requested_pages,
> +                                 !is_write ? FOLL_WRITE : 0,
>                                   pages);
>         if (ret <= 0)
>                 return -EFAULT;
> diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
> index cbe467ff1aba..f681b3e9e970 100644
> --- a/drivers/rapidio/devices/rio_mport_cdev.c
> +++ b/drivers/rapidio/devices/rio_mport_cdev.c
> @@ -868,7 +868,9 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
>
>                 pinned = get_user_pages_fast(
>                                 (unsigned long)xfer->loc_addr & PAGE_MASK,
> -                               nr_pages, dir == DMA_FROM_DEVICE, page_list);
> +                               nr_pages,
> +                               dir == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
> +                               page_list);
>
>                 if (pinned != nr_pages) {
>                         if (pinned < 0) {
> diff --git a/drivers/sbus/char/oradax.c b/drivers/sbus/char/oradax.c
> index 6516bc3cb58b..790aa148670d 100644
> --- a/drivers/sbus/char/oradax.c
> +++ b/drivers/sbus/char/oradax.c
> @@ -437,7 +437,7 @@ static int dax_lock_page(void *va, struct page **p)
>
>         dax_dbg("uva %p", va);
>
> -       ret = get_user_pages_fast((unsigned long)va, 1, 1, p);
> +       ret = get_user_pages_fast((unsigned long)va, 1, FOLL_WRITE, p);
>         if (ret == 1) {
>                 dax_dbg("locked page %p, for VA %p", *p, va);
>                 return 0;
> diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
> index 7ff22d3f03e3..871b25914c07 100644
> --- a/drivers/scsi/st.c
> +++ b/drivers/scsi/st.c
> @@ -4918,7 +4918,8 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
>
>          /* Try to fault in all of the necessary pages */
>          /* rw==READ means read from drive, write into memory area */
> -       res = get_user_pages_fast(uaddr, nr_pages, rw == READ, pages);
> +       res = get_user_pages_fast(uaddr, nr_pages, rw == READ ? FOLL_WRITE : 0,
> +                                 pages);
>
>         /* Errors and no page mapped should return here */
>         if (res < nr_pages)
> diff --git a/drivers/staging/gasket/gasket_page_table.c b/drivers/staging/gasket/gasket_page_table.c
> index 26755d9ca41d..f67fdf1d3817 100644
> --- a/drivers/staging/gasket/gasket_page_table.c
> +++ b/drivers/staging/gasket/gasket_page_table.c
> @@ -486,8 +486,8 @@ static int gasket_perform_mapping(struct gasket_page_table *pg_tbl,
>                         ptes[i].dma_addr = pg_tbl->coherent_pages[0].paddr +
>                                            off + i * PAGE_SIZE;
>                 } else {
> -                       ret = get_user_pages_fast(page_addr - offset, 1, 1,
> -                                                 &page);
> +                       ret = get_user_pages_fast(page_addr - offset, 1,
> +                                                 FOLL_WRITE, &page);
>
>                         if (ret <= 0) {
>                                 dev_err(pg_tbl->device,
> diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
> index 0b9ab1d0dd45..49fd7312e2aa 100644
> --- a/drivers/tee/tee_shm.c
> +++ b/drivers/tee/tee_shm.c
> @@ -273,7 +273,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
>                 goto err;
>         }
>
> -       rc = get_user_pages_fast(start, num_pages, 1, shm->pages);
> +       rc = get_user_pages_fast(start, num_pages, FOLL_WRITE, shm->pages);
>         if (rc > 0)
>                 shm->num_pages = rc;
>         if (rc != num_pages) {
> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> index c424913324e3..a4b10bb4086b 100644
> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> @@ -532,7 +532,8 @@ static int tce_iommu_use_page(unsigned long tce, unsigned long *hpa)
>         enum dma_data_direction direction = iommu_tce_direction(tce);
>
>         if (get_user_pages_fast(tce & PAGE_MASK, 1,
> -                       direction != DMA_TO_DEVICE, &page) != 1)
> +                       direction != DMA_TO_DEVICE ? FOLL_WRITE : 0,
> +                       &page) != 1)
>                 return -EFAULT;
>
>         *hpa = __pa((unsigned long) page_address(page));
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 24a129fcdd61..72685b1659ff 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1700,7 +1700,7 @@ static int set_bit_to_user(int nr, void __user *addr)
>         int bit = nr + (log % PAGE_SIZE) * 8;
>         int r;
>
> -       r = get_user_pages_fast(log, 1, 1, &page);
> +       r = get_user_pages_fast(log, 1, FOLL_WRITE, &page);
>         if (r < 0)
>                 return r;
>         BUG_ON(r != 1);
> diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
> index 8a53d1de611d..41390c8e0f67 100644
> --- a/drivers/video/fbdev/pvr2fb.c
> +++ b/drivers/video/fbdev/pvr2fb.c
> @@ -686,7 +686,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
>         if (!pages)
>                 return -ENOMEM;
>
> -       ret = get_user_pages_fast((unsigned long)buf, nr_pages, true, pages);
> +       ret = get_user_pages_fast((unsigned long)buf, nr_pages, FOLL_WRITE, pages);
>         if (ret < nr_pages) {
>                 nr_pages = ret;
>                 ret = -EINVAL;
> diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
> index 8ba726e600e9..6446bcab4185 100644
> --- a/drivers/virt/fsl_hypervisor.c
> +++ b/drivers/virt/fsl_hypervisor.c
> @@ -244,7 +244,7 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
>
>         /* Get the physical addresses of the source buffer */
>         num_pinned = get_user_pages_fast(param.local_vaddr - lb_offset,
> -               num_pages, param.source != -1, pages);
> +               num_pages, param.source != -1 ? FOLL_WRITE : 0, pages);
>
>         if (num_pinned != num_pages) {
>                 /* get_user_pages() failed */
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 5efc5eee9544..7b47f1e6aab4 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -852,7 +852,7 @@ static int gntdev_get_page(struct gntdev_copy_batch *batch, void __user *virt,
>         unsigned long xen_pfn;
>         int ret;
>
> -       ret = get_user_pages_fast(addr, 1, writeable, &page);
> +       ret = get_user_pages_fast(addr, 1, writeable ? FOLL_WRITE : 0, &page);
>         if (ret < 0)
>                 return ret;
>
> diff --git a/fs/orangefs/orangefs-bufmap.c b/fs/orangefs/orangefs-bufmap.c
> index 443bcd8c3c19..5a7c4fda682f 100644
> --- a/fs/orangefs/orangefs-bufmap.c
> +++ b/fs/orangefs/orangefs-bufmap.c
> @@ -269,7 +269,7 @@ orangefs_bufmap_map(struct orangefs_bufmap *bufmap,
>
>         /* map the pages */
>         ret = get_user_pages_fast((unsigned long)user_desc->ptr,
> -                            bufmap->page_count, 1, bufmap->page_array);
> +                            bufmap->page_count, FOLL_WRITE, bufmap->page_array);
>
>         if (ret < 0)
>                 return ret;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 05a105d9d4c3..8e1f3cd7482a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1537,8 +1537,8 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>                     struct page **pages, unsigned int gup_flags);
>
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages);
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages);
>
>  /* Container for pinned pfns / pages */
>  struct frame_vector {
> diff --git a/kernel/futex.c b/kernel/futex.c
> index fdd312da0992..e10209946f8b 100644
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -546,7 +546,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
>         if (unlikely(should_fail_futex(fshared)))
>                 return -EFAULT;
>
> -       err = get_user_pages_fast(address, 1, 1, &page);
> +       err = get_user_pages_fast(address, 1, FOLL_WRITE, &page);
>         /*
>          * If write access is not required (eg. FUTEX_WAIT), try
>          * and get read-only access.
> diff --git a/lib/iov_iter.c b/lib/iov_iter.c
> index be4bd627caf0..6dbae0692719 100644
> --- a/lib/iov_iter.c
> +++ b/lib/iov_iter.c
> @@ -1280,7 +1280,9 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
>                         len = maxpages * PAGE_SIZE;
>                 addr &= ~(PAGE_SIZE - 1);
>                 n = DIV_ROUND_UP(len, PAGE_SIZE);
> -               res = get_user_pages_fast(addr, n, iov_iter_rw(i) != WRITE, pages);
> +               res = get_user_pages_fast(addr, n,
> +                               iov_iter_rw(i) != WRITE ?  FOLL_WRITE : 0,
> +                               pages);
>                 if (unlikely(res < 0))
>                         return res;
>                 return (res == n ? len : res * PAGE_SIZE) - *start;
> @@ -1361,7 +1363,8 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
>                 p = get_pages_array(n);
>                 if (!p)
>                         return -ENOMEM;
> -               res = get_user_pages_fast(addr, n, iov_iter_rw(i) != WRITE, p);
> +               res = get_user_pages_fast(addr, n,
> +                               iov_iter_rw(i) != WRITE ?  FOLL_WRITE : 0, p);
>                 if (unlikely(res < 0)) {
>                         kvfree(p);
>                         return res;
> diff --git a/mm/gup.c b/mm/gup.c
> index 681388236106..6f32d36b3c5b 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1863,7 +1863,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
>   * @nr_pages:  number of pages from start to pin
> - * @write:     whether pages will be written to
> + * @gup_flags: flags modifying pin behaviour
>   * @pages:     array that receives pointers to the pages pinned.
>   *             Should be at least nr_pages long.
>   *
> @@ -1875,8 +1875,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
>   * were pinned, returns -errno.
>   */
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages)
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages)
>  {
>         unsigned long addr, len, end;
>         int nr = 0, ret = 0;
> @@ -1894,7 +1894,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>
>         if (gup_fast_permitted(start, nr_pages)) {
>                 local_irq_disable();
> -               gup_pgd_range(addr, end, write ? FOLL_WRITE : 0, pages, &nr);
> +               gup_pgd_range(addr, end, gup_flags, pages, &nr);
>                 local_irq_enable();
>                 ret = nr;
>         }
> @@ -1905,7 +1905,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>                 pages += nr;
>
>                 ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
> -                               write ? FOLL_WRITE : 0);
> +                                             gup_flags);
>
>                 /* Have to be a bit careful with return values */
>                 if (nr > 0) {
> diff --git a/mm/util.c b/mm/util.c
> index 1ea055138043..01ffe145c62b 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -306,7 +306,7 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
>   * @nr_pages:  number of pages from start to pin
> - * @write:     whether pages will be written to
> + * @gup_flags: flags modifying pin behaviour
>   * @pages:     array that receives pointers to the pages pinned.
>   *             Should be at least nr_pages long.
>   *
> @@ -327,10 +327,10 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
>   * get_user_pages_fast simply falls back to get_user_pages.
>   */
>  int __weak get_user_pages_fast(unsigned long start,
> -                               int nr_pages, int write, struct page **pages)
> +                               int nr_pages, unsigned int gup_flags,
> +                               struct page **pages)
>  {
> -       return get_user_pages_unlocked(start, nr_pages, pages,
> -                                      write ? FOLL_WRITE : 0);
> +       return get_user_pages_unlocked(start, nr_pages, pages, gup_flags);
>  }
>  EXPORT_SYMBOL_GPL(get_user_pages_fast);
>
> diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
> index d3736f5bffec..74cafc0142ea 100644
> --- a/net/ceph/pagevec.c
> +++ b/net/ceph/pagevec.c
> @@ -27,7 +27,7 @@ struct page **ceph_get_direct_page_vector(const void __user *data,
>         while (got < num_pages) {
>                 rc = get_user_pages_fast(
>                     (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
> -                   num_pages - got, write_page, pages + got);
> +                   num_pages - got, write_page ? FOLL_WRITE : 0, pages + got);
>                 if (rc < 0)
>                         break;
>                 BUG_ON(rc == 0);
> diff --git a/net/rds/info.c b/net/rds/info.c
> index e367a97a18c8..03f6fd56d237 100644
> --- a/net/rds/info.c
> +++ b/net/rds/info.c
> @@ -193,7 +193,7 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
>                 ret = -ENOMEM;
>                 goto out;
>         }
> -       ret = get_user_pages_fast(start, nr_pages, 1, pages);
> +       ret = get_user_pages_fast(start, nr_pages, FOLL_WRITE, pages);
>         if (ret != nr_pages) {
>                 if (ret > 0)
>                         nr_pages = ret;
> diff --git a/net/rds/rdma.c b/net/rds/rdma.c
> index 182ab8430594..b340ed4fc43a 100644
> --- a/net/rds/rdma.c
> +++ b/net/rds/rdma.c
> @@ -158,7 +158,8 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
>  {
>         int ret;
>
> -       ret = get_user_pages_fast(user_addr, nr_pages, write, pages);
> +       ret = get_user_pages_fast(user_addr, nr_pages, write ? FOLL_WRITE : 0,
> +                                 pages);
>
>         if (ret >= 0 && ret < nr_pages) {
>                 while (ret--)
> --
> 2.20.1
>

