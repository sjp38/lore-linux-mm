Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 53F1D6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 10:05:10 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so7251901pde.38
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 07:05:09 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1VR0ZU-0006zR-Id
	for linux-mm@kvack.org; Tue, 01 Oct 2013 16:05:04 +0200
Received: from 217-67-201-162.itsa.net.pl ([217.67.201.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 16:05:04 +0200
Received: from k.kozlowski by 217-67-201-162.itsa.net.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 16:05:04 +0200
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: Re: [PATCH 7/8] vrange: Add method to purge volatile ranges
Date: Tue, 01 Oct 2013 16:00:27 +0200
Message-ID: <1380636027.30613.1.camel@AMDC1943>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
	 <1371010971-15647-8-git-send-email-john.stultz@linaro.org>
	 <20130619043419.GA10961@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20130619043419.GA10961@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi

On =C5=9Bro, 2013-06-19 at 13:34 +0900, Minchan Kim wrote:
> +int try_to_discard_one(struct vrange_root *vroot, struct page *page,
> +			struct vm_area_struct *vma, unsigned long addr)
> +{
> +	struct mm_struct *mm =3D vma->vm_mm;
> +	pte_t *pte;
> +	pte_t pteval;
> +	spinlock_t *ptl;
> +	int ret =3D 0;
> +	bool present;
> +
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	vrange_lock(vroot);
> +	pte =3D vpage_check_address(page, mm, addr, &ptl);
> +	if (!pte)
> +		goto out;
> +
> +	if (vma->vm_flags & VM_LOCKED) {
> +		pte_unmap_unlock(pte, ptl);
> +		goto out;
> +	}
> +
> +	present =3D pte_present(*pte);
> +	flush_cache_page(vma, address, page_to_pfn(page));

Compilation error during porting to ARM:
s/address/addr


Best regards,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
