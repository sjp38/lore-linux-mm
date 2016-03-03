Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBCF6B0261
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:07:05 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id xx9so34832423obc.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:07:05 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id di4si470238oeb.17.2016.03.03.15.07.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 15:07:04 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
Date: Thu, 3 Mar 2016 23:05:57 +0000
Message-ID: <20160303230556.GA9263@hori1.linux.bs1.fc.nec.co.jp>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
In-Reply-To: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3A6AFC719D9D064B949D60A5B14CE109@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>

On Thu, Mar 03, 2016 at 11:02:51AM +0100, Jan Stancek wrote:
> Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> this value is propagated to userspace. EOPNOTSUPP is part of uapi
> and is widely supported by libc libraries.
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>=20
> Signed-off-by: Jan Stancek <jstancek@redhat.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hugetlb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 01f2b48c8618..851a29928a99 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2751,7 +2751,7 @@ static int hugetlb_sysctl_handler_common(bool obey_=
mempolicy,
>  	int ret;
> =20
>  	if (!hugepages_supported())
> -		return -ENOTSUPP;
> +		return -EOPNOTSUPP;
> =20
>  	table->data =3D &tmp;
>  	table->maxlen =3D sizeof(unsigned long);
> @@ -2792,7 +2792,7 @@ int hugetlb_overcommit_handler(struct ctl_table *ta=
ble, int write,
>  	int ret;
> =20
>  	if (!hugepages_supported())
> -		return -ENOTSUPP;
> +		return -EOPNOTSUPP;
> =20
>  	tmp =3D h->nr_overcommit_huge_pages;
> =20
> --=20
> 1.8.3.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
