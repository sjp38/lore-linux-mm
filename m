Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7AA3F6B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 11:35:58 -0500 (EST)
Received: by yenq10 with SMTP id q10so7960764yen.14
        for <linux-mm@kvack.org>; Mon, 26 Dec 2011 08:35:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF89BCB.8070306@parallels.com>
References: <4EF78B6A.8020904@parallels.com> <4EF78B99.1020109@parallels.com>
 <CAHGf_=r5mmUJUaQLKgrY1rf9Qx0gO0hEJaHFehm5Zz7ZKMYUkQ@mail.gmail.com> <4EF89BCB.8070306@parallels.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 26 Dec 2011 11:35:36 -0500
Message-ID: <CAHGf_=rJhpQyhWiVk_BALM7SG=rgbVLscLMqdmmC4OLBR70mOA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mincore: Introduce the MINCORE_ANON bit
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

2011/12/26 Pavel Emelyanov <xemul@parallels.com>:
> On 12/26/2011 04:05 AM, KOSAKI Motohiro wrote:
>>> +static unsigned char mincore_pte(struct vm_area_struct *vma, unsigned =
long addr, pte_t pte)
>>> +{
>>> + =A0 =A0 =A0 struct page *pg;
>>> +
>>> + =A0 =A0 =A0 pg =3D vm_normal_page(vma, addr, pte);
>>> + =A0 =A0 =A0 if (!pg)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>> + =A0 =A0 =A0 else
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PageAnon(pg) ? MINCORE_ANON : 0;
>>> +}
>>> +
>>
>> How do your program handle tmpfs pages (and/or ram device pages)?
>
> Do you mean mapped files from tmpfs? Currently just any other file.
> Do you see problems with this patch wrt tmpfs?

If you don't save mapped file on tmpfs or other volatile devices, the proce=
ss
might not restored. The data might already destroyed. The common strategy
are two,

1) save all opened file by different ways.
2) save all mapped file even though clean file cache.

In both case, we don't reduce freezed data size. So, I'm interesting
you strategy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
