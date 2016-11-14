Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584866B0038
	for <linux-mm@kvack.org>; Sun, 13 Nov 2016 22:16:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so65879993pgd.0
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 19:16:36 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id 68si12111996pfn.75.2016.11.13.19.16.34
        for <linux-mm@kvack.org>;
        Sun, 13 Nov 2016 19:16:35 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161113033328.9250-1-jeremy.lefaure@lse.epita.fr>
In-Reply-To: <20161113033328.9250-1-jeremy.lefaure@lse.epita.fr>
Subject: Re: [PATCH] thb: propagate conditional compilation to code depending on sysfs in khugepaged.c
Date: Mon, 14 Nov 2016 11:16:21 +0800
Message-ID: <024001d23e25$79591900$6c0b4b00$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?'J=C3=A9r=C3=A9my_Lefaure'?= <jeremy.lefaure@lse.epita.fr>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org

>=20
> Commit b46e756f5e47 ("thp: extract khugepaged from mm/huge_memory.c")
> moved code from huge_memory.c to khugepaged.c. Some of this code =
should
> be compiled only when CONFIG_SYSFS is enabled but the condition around
> this code was not moved into khugepaged.c. The result is a compilation
> error when CONFIG_SYSFS is disabled:
>=20
> mm/built-in.o: In function `khugepaged_defrag_store':
> khugepaged.c:(.text+0x2d095): undefined reference to
> `single_hugepage_flag_store'
> mm/built-in.o: In function `khugepaged_defrag_show':
> khugepaged.c:(.text+0x2d0ab): undefined reference to
> `single_hugepage_flag_show'
>=20
> This commit adds the #ifdef CONFIG_SYSFS around the code related to
> sysfs.
>=20
> Signed-off-by: J=C3=A9r=C3=A9my Lefaure <jeremy.lefaure@lse.epita.fr>
> ---

Hey, can you spin with the subject line corrected, please?

>  mm/khugepaged.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 728d779..87e1a7ca 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -103,6 +103,7 @@ static struct khugepaged_scan khugepaged_scan =3D =
{
>  	.mm_head =3D LIST_HEAD_INIT(khugepaged_scan.mm_head),
>  };
>=20
> +#ifdef CONFIG_SYSFS
>  static ssize_t scan_sleep_millisecs_show(struct kobject *kobj,
>  					 struct kobj_attribute *attr,
>  					 char *buf)
> @@ -295,6 +296,7 @@ struct attribute_group khugepaged_attr_group =3D {
>  	.attrs =3D khugepaged_attr,
>  	.name =3D "khugepaged",
>  };
> +#endif /* CONFIG_SYSFS */
>=20
>  #define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB)
>=20
> --
> 2.10.2
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
