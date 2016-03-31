Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6509C6B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 21:08:04 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so56003161pfn.2
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 18:08:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id z12si314556pas.77.2016.03.30.18.08.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 18:08:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id u2V180Xj021191
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 10:08:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: optimize minimum size (min_size) accounting
Date: Thu, 31 Mar 2016 01:00:03 +0000
Message-ID: <20160331010002.GA20652@hori1.linux.bs1.fc.nec.co.jp>
References: <1458949498-18916-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1458949498-18916-1-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F6C7899D45B4694082D391F411FF5D2E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>

On Fri, Mar 25, 2016 at 04:44:58PM -0700, Mike Kravetz wrote:
> It was observed that minimum size accounting associated with the
> hugetlbfs min_size mount option may not perform optimally and as
> expected.  As huge pages/reservations are released from the filesystem
> and given back to the global pools, they are reserved for subsequent
> filesystem use as long as the subpool reserved count is less than
> subpool minimum size.  It does not take into account used pages
> within the filesystem.  The filesystem size limits are not exceeded
> and this is technically not a bug.  However, better behavior would
> be to wait for the number of used pages/reservations associated with
> the filesystem to drop below the minimum size before taking reservations
> to satisfy minimum size.
>=20
> An optimization is also made to the hugepage_subpool_get_pages()
> routine which is called when pages/reservations are allocated.  This
> does not change behavior, but simply avoids the accounting if all
> reservations have already been taken (subpool reserved count =3D=3D 0).
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Seems OK to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
