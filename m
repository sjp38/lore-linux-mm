Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E1B1C6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 06:22:43 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so2239912pbc.36
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 03:22:43 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1VRg3F-0001E4-JW
	for linux-mm@kvack.org; Thu, 03 Oct 2013 12:22:33 +0200
Received: from 217-67-201-162.itsa.net.pl ([217.67.201.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 12:22:33 +0200
Received: from k.kozlowski by 217-67-201-162.itsa.net.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 12:22:33 +0200
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: Re: [PATCH 06/14] vrange: Add basic functions to purge volatile
 pages
Date: Thu, 03 Oct 2013 12:22:24 +0200
Message-ID: <1380795744.3392.3.camel@AMDC1943>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
	 <1380761503-14509-7-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1380761503-14509-7-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On =C5=9Bro, 2013-10-02 at 17:51 -0700, John Stultz wrote:
> +static void try_to_discard_one(struct vrange_root *vroot, struct page *p=
age,
> +				struct vm_area_struct *vma, unsigned long addr)
> +{
> +	struct mm_struct *mm =3D vma->vm_mm;
> +	pte_t *pte;
> +	pte_t pteval;
> +	spinlock_t *ptl;
> +
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	pte =3D page_check_address(page, mm, addr, &ptl, 0);
> +	if (!pte)
> +		return;
> +
> +	BUG_ON(vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|VM_HUGETLB));
> +
> +	flush_cache_page(vma, addr, page_to_pfn(page));

It seems that this patch is different in your GIT repo
(git://git.linaro.org/people/jstultz/android-dev.git dev/vrange-v9). In
GIT it is missing the fix: s/address/addr.

Best regards,
Krzysztof



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
