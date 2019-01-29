Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAE32C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:41:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 521AF20856
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:41:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="C9iTEo72"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521AF20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC52A8E0002; Tue, 29 Jan 2019 13:41:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73C28E0001; Tue, 29 Jan 2019 13:41:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3CF08E0002; Tue, 29 Jan 2019 13:41:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C44E8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:41:37 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w24so8046495otk.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:41:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=HL83ygIqpSTTKGQg55ygGuyvC6iG0KJllUYn+t+L7fo=;
        b=HRDNHzB2sveNaEhk02urUulSPNReJLeem0SlyzJCRG8SxIWc/IvZNeSGtuWZWY8lc2
         AzGwmslI1nirvg/YhRXAlfh6SxsxmPG8NUwpASvqYlQYv4WpDYzDR4eF9XvHCl8kHyRI
         MXa8J9SqW2MX7N6bXsrG3LGDfCZ5v8qW+eDbyjvT45M8uUe/MGwbjET+TjalQm9fuUKU
         dmhsHqewGCBUzJSFcQy61bkLdaohMjNrGnokKr5P1U7972x60yHfpCZ2DTAeag6MY91O
         fczQzi6gC6Rm83WC6ZkMswvLKX4taZDGVKrgqSxboVoLk7L6I4Cw+7t+qmPqFAHZx9Wc
         R+GA==
X-Gm-Message-State: AJcUukdJ1T0SAfBYq/VUbC5MPTNNFLupKQAZ9YWTYXi7WZzRecvTXXZk
	2nGTpPN2QNpB65CxMSSPXhpOcF3Ih32SiYj12L/tu0aaiOyFln9tW4g85OG9Lr1Le8cx24nfz8F
	qmwrzKAkwejG1E8bl8UmAkVCMGhgqVPXQIhzlAoJQXdKrwcZxciJ6pVE8C7/xCPOwGNI+uJtG8U
	Ygfenf9HBOrIuuHiNUSV9MenG+DPTxrqNhQhV92EOA0Fu1nyGVOqZTT1fI5F47at0HtHG8k4jVT
	/fgd3+ay9IfyNfb6QOG6x4XnrEmDAZ+KxpJLImdr52mvB/4ymxdthmE1t5xG9Q8uycNCBd+75eP
	AsnprMsJmKlGcWWKH6rOmY0La08mNoN/h/VgZTBJf/8eZnbxzWY8mylB6GsVDqESU6xHcbhQR0w
	O
X-Received: by 2002:a9d:7997:: with SMTP id h23mr19286241otm.362.1548787297258;
        Tue, 29 Jan 2019 10:41:37 -0800 (PST)
X-Received: by 2002:a9d:7997:: with SMTP id h23mr19286176otm.362.1548787295427;
        Tue, 29 Jan 2019 10:41:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787295; cv=none;
        d=google.com; s=arc-20160816;
        b=ymiIUmNw1yvb3qrjRvIH69JcWJ9jaJ7nXNeLNSR5YVn0syXpas41OeB/OifdW1Rc4e
         rUWEjPWmIJJMUf2KvISAO4DkHhzVilqju9NsVMrfO3Z/N8DHQGENCqUYVRySAEfixoUT
         YRbDXIs0DH3vxi1X+ZvBItl6xSjnVT2RuihKbtWTMjTHUOfms9htcJj3EwlBiFgeUXSN
         cWhsXX0e3hnTEWZurdEM3xa6j4DU5i+3bwfczP25FdPim/PQYZBQREG1C/LlE4ATRG+V
         gUPiB8cz4mcWQYGUTgc2rIO31lMr7JaFUaOXGYXbEWjO9UbBShGUOvGNjckkqpDD4XTj
         9VYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=HL83ygIqpSTTKGQg55ygGuyvC6iG0KJllUYn+t+L7fo=;
        b=fKWi/j5wNkX5QwVqnh3/meBcrro5cwZz5wGYfk1dUV1T8uxyx65Q+g6+BLk+5EpntT
         dyU1ewhf5uJ+d80MFzs7/LV8C3RyImB+VedCP0RCxEGlPuFPs3Q9YlhuwSXhNBvQ7oaX
         nAFUdryNw/Jsvub64hYqSW3KBtJmzC6O8YlSevPGxQzP8Q4U5P9oAzHKVAcyzPkjSMzV
         FdI3pg++4V/5hieo8U6cjxMA7sIzgHV86VSa54MjHDaRPONC88vke+Tv6b1UlvcA5E2A
         qyh+OMuZwX8CdQQ+nefDz2TeuRT8GJYQzbm/jPXTGcey3DR+IOQTd+YJj/BRb7e/ltG1
         FQqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=C9iTEo72;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i130sor8239272oif.95.2019.01.29.10.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:41:35 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=C9iTEo72;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=HL83ygIqpSTTKGQg55ygGuyvC6iG0KJllUYn+t+L7fo=;
        b=C9iTEo72hAQPj1VLygRAYbRemfwQw/wdjdXDB3e/eclhA3asML1sVcibMctJEo6uvM
         UzOOCIoV4igwfhs+BOKVOb0NxKQHX2mLoe8zTN3ipepSsA7CJPAms4TelPvV+lEjs7NS
         pusDqWXYQz/xLw4ddjbankm+UWcc6n3w2WKfNtD2q98fMZLd/SmA2TGcs+1zSKGaGNbB
         Jw5Wu0qyfVYCB6sDA9JS9NCp+tKRnBCdViSIy6ksZVgWPNi+MGPcLByDcG16oUtSJCp6
         GG09SsSyEVlXkjPiF7ZobCb6Pwh05ezDJtreAqFoLVpnb+I50qvxDtXBG+iI7KAoqZmr
         IxGg==
X-Google-Smtp-Source: AHgI3IYljlwfixZbEW9k35QADvn426C06Y3dCzjYEAwUUk9JxY2Lr5SqZvdOmBetvdgd9kgxSjPcJbFa3Dw6Aldoo9c=
X-Received: by 2002:aca:d905:: with SMTP id q5mr10434566oig.0.1548787294934;
 Tue, 29 Jan 2019 10:41:34 -0800 (PST)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190129165428.3931-10-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-10-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 29 Jan 2019 10:41:23 -0800
Message-ID: <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 8:54 AM <jglisse@redhat.com> wrote:
>
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> This add support to mirror vma which is an mmap of a file which is on
> a filesystem that using a DAX block device. There is no reason not to
> support that case.
>

The reason not to support it would be if it gets in the way of future
DAX development. How does this interact with MAP_SYNC? I'm also
concerned if this complicates DAX reflink support. In general I'd
rather prioritize fixing the places where DAX is broken today before
adding more cross-subsystem entanglements. The unit tests for
filesystems (xfstests) are readily accessible. How would I go about
regression testing DAX + HMM interactions?

> Note that unlike GUP code we do not take page reference hence when we
> back-off we have nothing to undo.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 133 ++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 112 insertions(+), 21 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8b87e1813313..1a444885404e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -334,6 +334,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
>
>  struct hmm_vma_walk {
>         struct hmm_range        *range;
> +       struct dev_pagemap      *pgmap;
>         unsigned long           last;
>         bool                    fault;
>         bool                    block;
> @@ -508,6 +509,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct h=
mm_range *range, pmd_t pmd)
>                                 range->flags[HMM_PFN_VALID];
>  }
>
> +static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud=
_t pud)
> +{
> +       if (!pud_present(pud))
> +               return 0;
> +       return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
> +                               range->flags[HMM_PFN_WRITE] :
> +                               range->flags[HMM_PFN_VALID];
> +}
> +
>  static int hmm_vma_handle_pmd(struct mm_walk *walk,
>                               unsigned long addr,
>                               unsigned long end,
> @@ -529,8 +539,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
>                 return hmm_vma_walk_hole_(addr, end, fault, write_fault, =
walk);
>
>         pfn =3D pmd_pfn(pmd) + pte_index(addr);
> -       for (i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++, pfn++)
> +       for (i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++, pfn++) {
> +               if (pmd_devmap(pmd)) {
> +                       hmm_vma_walk->pgmap =3D get_dev_pagemap(pfn,
> +                                             hmm_vma_walk->pgmap);
> +                       if (unlikely(!hmm_vma_walk->pgmap))
> +                               return -EBUSY;
> +               }
>                 pfns[i] =3D hmm_pfn_from_pfn(range, pfn) | cpu_flags;
> +       }
> +       if (hmm_vma_walk->pgmap) {
> +               put_dev_pagemap(hmm_vma_walk->pgmap);
> +               hmm_vma_walk->pgmap =3D NULL;
> +       }
>         hmm_vma_walk->last =3D end;
>         return 0;
>  }
> @@ -617,10 +638,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk,=
 unsigned long addr,
>         if (fault || write_fault)
>                 goto fault;
>
> +       if (pte_devmap(pte)) {
> +               hmm_vma_walk->pgmap =3D get_dev_pagemap(pte_pfn(pte),
> +                                             hmm_vma_walk->pgmap);
> +               if (unlikely(!hmm_vma_walk->pgmap))
> +                       return -EBUSY;
> +       } else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special=
(pte)) {
> +               *pfn =3D range->values[HMM_PFN_SPECIAL];
> +               return -EFAULT;
> +       }
> +
>         *pfn =3D hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
>         return 0;
>
>  fault:
> +       if (hmm_vma_walk->pgmap) {
> +               put_dev_pagemap(hmm_vma_walk->pgmap);
> +               hmm_vma_walk->pgmap =3D NULL;
> +       }
>         pte_unmap(ptep);
>         /* Fault any virtual address we were asked to fault */
>         return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> @@ -708,12 +743,84 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>                         return r;
>                 }
>         }
> +       if (hmm_vma_walk->pgmap) {
> +               put_dev_pagemap(hmm_vma_walk->pgmap);
> +               hmm_vma_walk->pgmap =3D NULL;
> +       }
>         pte_unmap(ptep - 1);
>
>         hmm_vma_walk->last =3D addr;
>         return 0;
>  }
>
> +static int hmm_vma_walk_pud(pud_t *pudp,
> +                           unsigned long start,
> +                           unsigned long end,
> +                           struct mm_walk *walk)
> +{
> +       struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +       struct hmm_range *range =3D hmm_vma_walk->range;
> +       struct vm_area_struct *vma =3D walk->vma;
> +       unsigned long addr =3D start, next;
> +       pmd_t *pmdp;
> +       pud_t pud;
> +       int ret;
> +
> +again:
> +       pud =3D READ_ONCE(*pudp);
> +       if (pud_none(pud))
> +               return hmm_vma_walk_hole(start, end, walk);
> +
> +       if (pud_huge(pud) && pud_devmap(pud)) {
> +               unsigned long i, npages, pfn;
> +               uint64_t *pfns, cpu_flags;
> +               bool fault, write_fault;
> +
> +               if (!pud_present(pud))
> +                       return hmm_vma_walk_hole(start, end, walk);
> +
> +               i =3D (addr - range->start) >> PAGE_SHIFT;
> +               npages =3D (end - addr) >> PAGE_SHIFT;
> +               pfns =3D &range->pfns[i];
> +
> +               cpu_flags =3D pud_to_hmm_pfn_flags(range, pud);
> +               hmm_range_need_fault(hmm_vma_walk, pfns, npages,
> +                                    cpu_flags, &fault, &write_fault);
> +               if (fault || write_fault)
> +                       return hmm_vma_walk_hole_(addr, end, fault,
> +                                               write_fault, walk);
> +
> +               pfn =3D pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT)=
;
> +               for (i =3D 0; i < npages; ++i, ++pfn) {
> +                       hmm_vma_walk->pgmap =3D get_dev_pagemap(pfn,
> +                                             hmm_vma_walk->pgmap);
> +                       if (unlikely(!hmm_vma_walk->pgmap))
> +                               return -EBUSY;
> +                       pfns[i] =3D hmm_pfn_from_pfn(range, pfn) | cpu_fl=
ags;
> +               }
> +               if (hmm_vma_walk->pgmap) {
> +                       put_dev_pagemap(hmm_vma_walk->pgmap);
> +                       hmm_vma_walk->pgmap =3D NULL;
> +               }
> +               hmm_vma_walk->last =3D end;
> +               return 0;
> +       }
> +
> +       split_huge_pud(vma, pudp, addr);
> +       if (pud_none(*pudp))
> +               goto again;
> +
> +       pmdp =3D pmd_offset(pudp, addr);
> +       do {
> +               next =3D pmd_addr_end(addr, end);
> +               ret =3D hmm_vma_walk_pmd(pmdp, addr, next, walk);
> +               if (ret)
> +                       return ret;
> +       } while (pmdp++, addr =3D next, addr !=3D end);
> +
> +       return 0;
> +}
> +
>  static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
>                                       unsigned long start, unsigned long =
end,
>                                       struct mm_walk *walk)
> @@ -786,14 +893,6 @@ static void hmm_pfns_clear(struct hmm_range *range,
>                 *pfns =3D range->values[HMM_PFN_NONE];
>  }
>
> -static void hmm_pfns_special(struct hmm_range *range)
> -{
> -       unsigned long addr =3D range->start, i =3D 0;
> -
> -       for (; addr < range->end; addr +=3D PAGE_SIZE, i++)
> -               range->pfns[i] =3D range->values[HMM_PFN_SPECIAL];
> -}
> -
>  /*
>   * hmm_range_register() - start tracking change to CPU page table over a=
 range
>   * @range: range
> @@ -911,12 +1010,6 @@ long hmm_range_snapshot(struct hmm_range *range)
>                 if (vma =3D=3D NULL || (vma->vm_flags & device_vma))
>                         return -EFAULT;
>
> -               /* FIXME support dax */
> -               if (vma_is_dax(vma)) {
> -                       hmm_pfns_special(range);
> -                       return -EINVAL;
> -               }
> -
>                 if (is_vm_hugetlb_page(vma)) {
>                         struct hstate *h =3D hstate_vma(vma);
>
> @@ -940,6 +1033,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>                 }
>
>                 range->vma =3D vma;
> +               hmm_vma_walk.pgmap =3D NULL;
>                 hmm_vma_walk.last =3D start;
>                 hmm_vma_walk.fault =3D false;
>                 hmm_vma_walk.range =3D range;
> @@ -951,6 +1045,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>                 mm_walk.pte_entry =3D NULL;
>                 mm_walk.test_walk =3D NULL;
>                 mm_walk.hugetlb_entry =3D NULL;
> +               mm_walk.pud_entry =3D hmm_vma_walk_pud;
>                 mm_walk.pmd_entry =3D hmm_vma_walk_pmd;
>                 mm_walk.pte_hole =3D hmm_vma_walk_hole;
>                 mm_walk.hugetlb_entry =3D hmm_vma_walk_hugetlb_entry;
> @@ -1018,12 +1113,6 @@ long hmm_range_fault(struct hmm_range *range, bool=
 block)
>                 if (vma =3D=3D NULL || (vma->vm_flags & device_vma))
>                         return -EFAULT;
>
> -               /* FIXME support dax */
> -               if (vma_is_dax(vma)) {
> -                       hmm_pfns_special(range);
> -                       return -EINVAL;
> -               }
> -
>                 if (is_vm_hugetlb_page(vma)) {
>                         struct hstate *h =3D hstate_vma(vma);
>
> @@ -1047,6 +1136,7 @@ long hmm_range_fault(struct hmm_range *range, bool =
block)
>                 }
>
>                 range->vma =3D vma;
> +               hmm_vma_walk.pgmap =3D NULL;
>                 hmm_vma_walk.last =3D start;
>                 hmm_vma_walk.fault =3D true;
>                 hmm_vma_walk.block =3D block;
> @@ -1059,6 +1149,7 @@ long hmm_range_fault(struct hmm_range *range, bool =
block)
>                 mm_walk.pte_entry =3D NULL;
>                 mm_walk.test_walk =3D NULL;
>                 mm_walk.hugetlb_entry =3D NULL;
> +               mm_walk.pud_entry =3D hmm_vma_walk_pud;
>                 mm_walk.pmd_entry =3D hmm_vma_walk_pmd;
>                 mm_walk.pte_hole =3D hmm_vma_walk_hole;
>                 mm_walk.hugetlb_entry =3D hmm_vma_walk_hugetlb_entry;
> --
> 2.17.2
>

