Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 256716B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 11:07:49 -0500 (EST)
Message-ID: <4EF89BCB.8070306@parallels.com>
Date: Mon, 26 Dec 2011 20:07:39 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mincore: Introduce the MINCORE_ANON bit
References: <4EF78B6A.8020904@parallels.com> <4EF78B99.1020109@parallels.com> <CAHGf_=r5mmUJUaQLKgrY1rf9Qx0gO0hEJaHFehm5Zz7ZKMYUkQ@mail.gmail.com>
In-Reply-To: <CAHGf_=r5mmUJUaQLKgrY1rf9Qx0gO0hEJaHFehm5Zz7ZKMYUkQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On 12/26/2011 04:05 AM, KOSAKI Motohiro wrote:
>> +static unsigned char mincore_pte(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
>> +{
>> +       struct page *pg;
>> +
>> +       pg = vm_normal_page(vma, addr, pte);
>> +       if (!pg)
>> +               return 0;
>> +       else
>> +               return PageAnon(pg) ? MINCORE_ANON : 0;
>> +}
>> +
> 
> How do your program handle tmpfs pages (and/or ram device pages)?
> .

Do you mean mapped files from tmpfs? Currently just any other file.
Do you see problems with this patch wrt tmpfs?

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
