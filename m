Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5216B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 21:32:15 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so317049pad.16
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 18:32:15 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id ht10so98863vcb.10
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 18:32:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1380636027.30613.1.camel@AMDC1943>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
	<1371010971-15647-8-git-send-email-john.stultz@linaro.org>
	<20130619043419.GA10961@bbox>
	<1380636027.30613.1.camel@AMDC1943>
Date: Wed, 2 Oct 2013 10:32:12 +0900
Message-ID: <CAEwNFnAg+1VnRUv_oeNcJxRaCXCO+FmRR_ijO-r+2u6bzQEBVw@mail.gmail.com>
Subject: Re: [PATCH 7/8] vrange: Add method to purge volatile ranges
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>

Hello, Krzysztof

Thanks for the fix!
Just FYI,
I and John found many bugs and changed lots of code and will send it
to upstream, maybe end of this week or next week.

Thanks!

On Tue, Oct 1, 2013 at 11:00 PM, Krzysztof Kozlowski
<k.kozlowski@samsung.com> wrote:
> Hi
>
> On =C5=9Bro, 2013-06-19 at 13:34 +0900, Minchan Kim wrote:
>> +int try_to_discard_one(struct vrange_root *vroot, struct page *page,
>> +                     struct vm_area_struct *vma, unsigned long addr)
>> +{
>> +     struct mm_struct *mm =3D vma->vm_mm;
>> +     pte_t *pte;
>> +     pte_t pteval;
>> +     spinlock_t *ptl;
>> +     int ret =3D 0;
>> +     bool present;
>> +
>> +     VM_BUG_ON(!PageLocked(page));
>> +
>> +     vrange_lock(vroot);
>> +     pte =3D vpage_check_address(page, mm, addr, &ptl);
>> +     if (!pte)
>> +             goto out;
>> +
>> +     if (vma->vm_flags & VM_LOCKED) {
>> +             pte_unmap_unlock(pte, ptl);
>> +             goto out;
>> +     }
>> +
>> +     present =3D pte_present(*pte);
>> +     flush_cache_page(vma, address, page_to_pfn(page));
>
> Compilation error during porting to ARM:
> s/address/addr
>
>
> Best regards,
> Krzysztof
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
