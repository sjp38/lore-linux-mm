Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACA06B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 19:56:54 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so122325123pac.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 16:56:54 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id v3si19868315pdh.200.2015.05.11.16.56.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 May 2015 16:56:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Date: Mon, 11 May 2015 23:56:25 +0000
Message-ID: <20150511235624.GB8513@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda> <20150511112924.GM16501@mwanda>
In-Reply-To: <20150511112924.GM16501@mwanda>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <788CA7358F03184496347376EF5DF4B7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 11, 2015 at 02:29:24PM +0300, Dan Carpenter wrote:
> On Mon, May 11, 2015 at 02:17:48PM +0300, Dan Carpenter wrote:
> > Hello Naoya Horiguchi,
> >=20
> > The patch c8721bbbdd36: "mm: memory-hotplug: enable memory hotplug to
> > handle hugepage" from Sep 11, 2013, leads to the following static
> > checker warning:
> >=20
> > 	mm/hugetlb.c:1203 dissolve_free_huge_pages()
> > 	warn: potential right shift more than type allows '9,18,64'
> >=20
> > mm/hugetlb.c
> >   1189  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned=
 long end_pfn)
> >   1190  {
> >   1191          unsigned int order =3D 8 * sizeof(void *);
> >                                      ^^^^^^^^^^^^^^^^^^
> > Let's say order is 64.
>=20
> Actually, the 64 here is just chosen to be an impossibly high number
> isn't it?

Right.

>  It's a bit complicated to understand that at first glance.

OK, so I added oneline comment in the patch in another email.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
