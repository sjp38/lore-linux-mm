Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC626B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:45:37 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so3358673wgh.7
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:45:36 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id q3si15583121wia.79.2014.01.16.07.45.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 07:45:35 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id b13so3358637wgh.7
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:45:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
Date: Thu, 16 Jan 2014 09:45:35 -0600
Message-ID: <CAPp3RGpWhx4uoTTiSkUe9rZ2iJjMW6O2u=xdWL7BSskse=61qw@mail.gmail.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
From: Robin Holt <robinmholt@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bb04c44fe7eb304f01850c0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--047d7bb04c44fe7eb304f01850c0
Content-Type: text/plain; charset=ISO-8859-1

I can not see how this works.  How is the return from
get_allocated_memblock_reserved_regions_info() stored and used without
being declared?  Maybe you are working off a different repo than Linus'
latest?  Your line 116 is my 114.  Maybe the message needs to be a bit more
descriptive and certain the bit after the '---' should be telling me what
this is applying against.

Robin


On Thu, Jan 16, 2014 at 7:33 AM, Philipp Hachtmann <
phacht@linux.vnet.ibm.com> wrote:

> This fixes an unused variable warning in nobootmem.c
>
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
> ---
>  mm/nobootmem.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index e2906a5..12cbb04 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -116,9 +116,13 @@ static unsigned long __init
> __free_memory_core(phys_addr_t start,
>  static unsigned long __init free_low_memory_core_early(void)
>  {
>         unsigned long count = 0;
> -       phys_addr_t start, end, size;
> +       phys_addr_t start, end;
>         u64 i;
>
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +       phys_addr_t size;
> +#endif
> +
>         for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
>                 count += __free_memory_core(start, end);
>
> --
> 1.8.4.5
>
>

--047d7bb04c44fe7eb304f01850c0
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:courier =
new,monospace">I can not see how this works.=A0 How is the return from get_=
allocated_memblock_reserved_regions_info() stored and used without being de=
clared?=A0 Maybe you are working off a different repo than Linus&#39; lates=
t?=A0 Your line 116 is my 114.=A0 Maybe the message needs to be a bit more =
descriptive and certain the bit after the &#39;---&#39; should be telling m=
e what this is applying against.<br>
<br>Robin<br></div></div><div class=3D"gmail_extra"><br><br><div class=3D"g=
mail_quote">On Thu, Jan 16, 2014 at 7:33 AM, Philipp Hachtmann <span dir=3D=
"ltr">&lt;<a href=3D"mailto:phacht@linux.vnet.ibm.com" target=3D"_blank">ph=
acht@linux.vnet.ibm.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">This fixes an unused variable warning in nob=
ootmem.c<br>
<br>
Signed-off-by: Philipp Hachtmann &lt;<a href=3D"mailto:phacht@linux.vnet.ib=
m.com">phacht@linux.vnet.ibm.com</a>&gt;<br>
---<br>
=A0mm/nobootmem.c | 6 +++++-<br>
=A01 file changed, 5 insertions(+), 1 deletion(-)<br>
<br>
diff --git a/mm/nobootmem.c b/mm/nobootmem.c<br>
index e2906a5..12cbb04 100644<br>
--- a/mm/nobootmem.c<br>
+++ b/mm/nobootmem.c<br>
@@ -116,9 +116,13 @@ static unsigned long __init __free_memory_core(phys_ad=
dr_t start,<br>
=A0static unsigned long __init free_low_memory_core_early(void)<br>
=A0{<br>
=A0 =A0 =A0 =A0 unsigned long count =3D 0;<br>
- =A0 =A0 =A0 phys_addr_t start, end, size;<br>
+ =A0 =A0 =A0 phys_addr_t start, end;<br>
=A0 =A0 =A0 =A0 u64 i;<br>
<br>
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK<br>
+ =A0 =A0 =A0 phys_addr_t size;<br>
+#endif<br>
+<br>
=A0 =A0 =A0 =A0 for_each_free_mem_range(i, NUMA_NO_NODE, &amp;start, &amp;e=
nd, NULL)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D __free_memory_core(start, end);<=
br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.8.4.5<br>
<br>
</font></span></blockquote></div><br></div>

--047d7bb04c44fe7eb304f01850c0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
