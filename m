Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 3FC536B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 19:05:30 -0500 (EST)
Received: by yhgm50 with SMTP id m50so6365395yhg.14
        for <linux-mm@kvack.org>; Sun, 25 Dec 2011 16:05:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF78B99.1020109@parallels.com>
References: <4EF78B6A.8020904@parallels.com> <4EF78B99.1020109@parallels.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 25 Dec 2011 19:05:08 -0500
Message-ID: <CAHGf_=r5mmUJUaQLKgrY1rf9Qx0gO0hEJaHFehm5Zz7ZKMYUkQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] mincore: Introduce the MINCORE_ANON bit
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

> +static unsigned char mincore_pte(struct vm_area_struct *vma, unsigned lo=
ng addr, pte_t pte)
> +{
> + =A0 =A0 =A0 struct page *pg;
> +
> + =A0 =A0 =A0 pg =3D vm_normal_page(vma, addr, pte);
> + =A0 =A0 =A0 if (!pg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PageAnon(pg) ? MINCORE_ANON : 0;
> +}
> +

How do your program handle tmpfs pages (and/or ram device pages)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
