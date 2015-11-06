Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 019F382F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 01:48:40 -0500 (EST)
Received: by oies6 with SMTP id s6so18565993oie.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 22:48:39 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id n6si5355575oex.76.2015.11.05.22.48.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 22:48:39 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hwpoison: adjust for new thp refcounting
Date: Fri, 6 Nov 2015 06:47:44 +0000
Message-ID: <20151106064743.GA30023@hori1.linux.bs1.fc.nec.co.jp>
References: <1446790309-15683-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <563C4955.3000300@oracle.com>
In-Reply-To: <563C4955.3000300@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E8BC13F0F3F89A4EBAF34CC8E116C5BD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Nov 06, 2015 at 01:31:49AM -0500, Sasha Levin wrote:
> On 11/06/2015 01:11 AM, Naoya Horiguchi wrote:
> > In the new refcounting, we no longer use tail->_mapcount to keep tail's
> > refcount, and thereby we can simplify get_hwpoison_page() and remove
> > put_hwpoison_page() (by replacing with put_page()).
>=20
> This is confusing for the reader (and some static analysis tools): this a=
dds
> put_page()s without corresponding get_page()s.
>=20
> Could we instead macro put_hwpoison_page() as put_page() for the sake of =
readability?

OK, I'll do this.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
