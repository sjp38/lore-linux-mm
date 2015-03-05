Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D9A746B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 03:33:03 -0500 (EST)
Received: by padet14 with SMTP id et14so44272337pad.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 00:33:03 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id o1si8512333pap.77.2015.03.05.00.33.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 00:33:03 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t258X0sq005164
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 5 Mar 2015 17:33:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: pagewalk: prevent positive return value of
 walk_page_test() from being passed to callers (Re: [PATCH] mm: fix do_mbind
 return value)
Date: Thu, 5 Mar 2015 08:27:29 +0000
Message-ID: <20150305082728.GC2878@hori1.linux.bs1.fc.nec.co.jp>
References: <54F7BD54.5060502@gmail.com>
 <alpine.DEB.2.10.1503042231250.15901@chino.kir.corp.google.com>
 <20150305080226.GA28441@hori1.linux.bs1.fc.nec.co.jp>
 <20150305080948.GB28441@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150305080948.GB28441@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0E6A7D440508504D96020ADCA1C6B788@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> > From 107fa3fb256bddff40a882c90af717af9863aed7 Mon Sep 17 00:00:00 2001
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Thu, 5 Mar 2015 16:37:37 +0900
> > Subject: [PATCH] mm: pagewalk: prevent positive return value of
> >  walk_page_test() from being passed to callers
> >=20
> > walk_page_test() is purely pagewalk's internal stuff, and its positive =
return
> > values are not intended to be passed to the callers of pagewalk. Howeve=
r, in
> > the current code if the last vma in the do-while loop in walk_page_rang=
e()
> > happens to return a positive value, it leaks outside walk_page_range().
> > So the user visible effect is invalid/unexpected return value (accordin=
g to
> > the reporter, mbind() causes it.)
> >=20
> > This patch fixes it simply by reinitializing the return value after che=
cked.
> >=20
> > Another exposed interface, walk_page_vma(), already returns 0 for such =
cases
> > so no problem.
> >=20
> > Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages=
_range()")
>=20
> This is not a right tag. To be precise, the bug was introduced by commit
> fafaa4264eba ("pagewalk: improve vma handling"), so
>=20
>   Fixes fafaa4264eba ("pagewalk: improve vma handling")
>=20
> is right.
>=20
> Thanks,
> Naoya Horiguchi
>=20
> > Reported-by: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>

Ah, I might be a kind of rude, the original idea was posted by Yoshii-san,
and I changed it, so I may as well add his Signed-off-by (additional to
Reported-by) ?=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
