Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8476D6B0038
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 20:38:15 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n184so51313808oig.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 17:38:15 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id f10si16095727oib.311.2016.11.23.17.38.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 17:38:14 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: fix false-positive WARN_ON() in truncate/invalidate
 for hugetlb
Date: Thu, 24 Nov 2016 01:37:25 +0000
Message-ID: <20161124013724.GA19704@hori1.linux.bs1.fc.nec.co.jp>
References: <20161123092326.169822-1-kirill.shutemov@linux.intel.com>
 <20161123093053.mjbnvn5zwxw5e6lk@black.fi.intel.com>
In-Reply-To: <20161123093053.mjbnvn5zwxw5e6lk@black.fi.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0B98C048BF816E4FAE6BD70C9FEB88A5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Doug Nelson <doug.nelson@intel.com>, "[4.8+]" <stable@vger.kernel.org>

On Wed, Nov 23, 2016 at 12:30:53PM +0300, Kirill A. Shutemov wrote:
> Sorry, forgot to commit local changes.
>=20
> ----8<----
>=20
> From 321379738fa2359385a38dfac838a83c261a382d Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Wed, 23 Nov 2016 12:05:30 +0300
> Subject: [PATCH] mm: fix false-positive WARN_ON() in truncate/invalidate =
for
>  hugetlb
>=20
> Hugetlb pages have ->index in size of the huge pages (PMD_SIZE or
> PUD_SIZE), not in PAGE_SIZE as other types of pages. This means we
> cannot user page_to_pgoff() to check whether we've got the right page
> for the radix-tree index.
>=20
> Let's introduce page_to_index() which would return radix-tree index for
> given page.
>=20
> We will be able to get rid of this once hugetlb will be switched to
> multi-order entries.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-and-tested-by: Doug Nelson <doug.nelson@intel.com>
> Fixes: fc127da085c2 ("truncate: handle file thp")
> Cc: <stable@vger.kernel.org> [4.8+]

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
