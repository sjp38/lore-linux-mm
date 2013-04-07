Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B7DE06B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 09:49:49 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hm14so1823617wib.3
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 06:49:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365326292-2761-1-git-send-email-k80ck80c@gmail.com>
References: <1365326292-2761-1-git-send-email-k80ck80c@gmail.com>
Date: Sun, 7 Apr 2013 21:49:47 +0800
Message-ID: <CANBD6kGLU_3cFa2irzvCNxUH7Vvkd6wTZ=q3b2k=LcKwjuGFkg@mail.gmail.com>
Subject: Re: [PATCH 1/1] mmap.c: find_vma: eliminate initial if(mm) check
From: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Content-Type: multipart/alternative; boundary=089e01227b94f3c3b004d9c59779
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: k80c <k80ck80c@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--089e01227b94f3c3b004d9c59779
Content-Type: text/plain; charset=UTF-8

I've sent the same patch and has been merged into -mm tree by Andrew Morton.

Thanks
Zhang

2013/4/7 k80c <k80ck80c@gmail.com>

> As per commit 841e31e5cc6219d62054788faa289b6ed682d068,
> we dont really need this if(mm) check anymore.
>
> A WARN_ON_ONCE was added just for safety, but there have been no bug
> reports about this so far.
>
> Removing this if(mm) check.
>
> Signed-off-by: k80c <k80ck80c@gmail.com>
> ---
>  mm/mmap.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0db0de1..b2c363f 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1935,9 +1935,6 @@ struct vm_area_struct *find_vma(struct mm_struct
> *mm, unsigned long addr)
>  {
>         struct vm_area_struct *vma = NULL;
>
> -       if (WARN_ON_ONCE(!mm))          /* Remove this in linux-3.6 */
> -               return NULL;
> -
>         /* Check the cache first. */
>         /* (Cache hit rate is typically around 35%.) */
>         vma = ACCESS_ONCE(mm->mmap_cache);
> --
> 1.7.5.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--089e01227b94f3c3b004d9c59779
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div>I&#39;ve sent the same patch and has been merged into -mm tree by Andr=
ew Morton.</div><div>=C2=A0</div><div>Thanks</div><div>Zhang<br><br></div><=
div class=3D"gmail_quote">2013/4/7 k80c <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:k80ck80c@gmail.com" target=3D"_blank">k80ck80c@gmail.com</a>&gt;</span=
><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;padding=
-left:1ex;border-left-color:rgb(204,204,204);border-left-width:1px;border-l=
eft-style:solid">As per commit 841e31e5cc6219d62054788faa289b6ed682d068,<br=
>

we dont really need this if(mm) check anymore.<br>
<br>
A WARN_ON_ONCE was added just for safety, but there have been no bug<br>
reports about this so far.<br>
<br>
Removing this if(mm) check.<br>
<br>
Signed-off-by: k80c &lt;<a href=3D"mailto:k80ck80c@gmail.com">k80ck80c@gmai=
l.com</a>&gt;<br>
---<br>
=C2=A0mm/mmap.c | =C2=A0 =C2=A03 ---<br>
=C2=A01 files changed, 0 insertions(+), 3 deletions(-)<br>
<br>
diff --git a/mm/mmap.c b/mm/mmap.c<br>
index 0db0de1..b2c363f 100644<br>
--- a/mm/mmap.c<br>
+++ b/mm/mmap.c<br>
@@ -1935,9 +1935,6 @@ struct vm_area_struct *find_vma(struct mm_struct *mm,=
 unsigned long addr)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma =3D NULL;<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 if (WARN_ON_ONCE(!mm)) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* Remove this in linux-3.6 */<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;<br>
-<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check the cache first. */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* (Cache hit rate is typically around 35%.) */=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 vma =3D ACCESS_ONCE(mm-&gt;mmap_cache);<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.7.5.4<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/" target=3D=
"_blank">http://www.tux.org/lkml/</a><br>
</font></span></blockquote></div><br>

--089e01227b94f3c3b004d9c59779--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
