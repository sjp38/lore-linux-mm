Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 51E876B0071
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 02:57:48 -0400 (EDT)
Received: by vws19 with SMTP id 19so1843705vws.14
        for <linux-mm@kvack.org>; Sun, 10 Oct 2010 23:57:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87aamm3si1.fsf@basil.nowhere.org>
References: <4CB1EBA2.8090409@gmail.com>
	<87aamm3si1.fsf@basil.nowhere.org>
Date: Mon, 11 Oct 2010 08:57:45 +0200
Message-ID: <AANLkTimGC_0W-=nSeoti6DLh5XNxvGwU6jqoGUkuOKPx@mail.gmail.com>
Subject: Re: [PATCH 14(16] pramfs: memory protection
From: Marco Stornelli <marco.stornelli@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Embedded <linux-embedded@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Tim Bird <tim.bird@am.sony.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2010/10/10 Andi Kleen <andi@firstfloor.org>:
> Marco Stornelli <marco.stornelli@gmail.com> writes:
>> +
>> + =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 pgd =3D pgd_offset(&init_mm, address);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 pud =3D pud_offset(pgd, address);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pud_none(*pud) || unlikely(pud_bad(*pud)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 pmd =3D pmd_offset(pud, address);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 ptep =3D pte_offset_kernel(pmd, addr);
>> + =A0 =A0 =A0 =A0 =A0 =A0 pte =3D *ptep;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pte_present(pte)) {
>
> This won't work at all on x86 because you don't handle large
> pages.

On x86 works because I tested. Maybe there's a particular
configuration with large pages. Sincerly I'm only an "user", so if
you/Linus or others want to change it or rewrite it, for me it's ok.
The pte manipulation are a bit out of scope for a fs, so I let the
things to the mm experts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
