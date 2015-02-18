Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 64B086B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 20:13:05 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so10502547pab.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 17:13:05 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id a10si19743028pat.37.2015.02.17.17.13.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 17:13:04 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t1I1D0Ah008329
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 10:13:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] mm, hugetlb: set PageLRU for in-use/active hugepages
Date: Wed, 18 Feb 2015 01:07:29 +0000
Message-ID: <20150218010714.GD4823@hori1.linux.bs1.fc.nec.co.jp>
References: <1424143299-7557-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150217093153.GA12875@hori1.linux.bs1.fc.nec.co.jp>
 <20150217155744.04db5a98d5a1820240eb2317@linux-foundation.org>
 <20150217160249.7d498e4bd0837748e8c6a5f0@linux-foundation.org>
In-Reply-To: <20150217160249.7d498e4bd0837748e8c6a5f0@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <62B63264538FD04C974466688F58B5DC@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Feb 17, 2015 at 04:02:49PM -0800, Andrew Morton wrote:
> On Tue, 17 Feb 2015 15:57:44 -0800 Andrew Morton <akpm@linux-foundation.o=
rg> wrote:
>=20
> > So if I'm understanding this correctly, hugepages never have PG_lru set
> > and so you are overloading that bit on hugepages to indicate that the
> > page is present on hstate->hugepage_activelist?
>=20
> And maybe we don't need to overload PG_lru at all?  There's plenty of
> free space in the compound page's *(page + 1).

Right, that's not necessary. So I'll use PG_private in *(page + 1), that's
unused now and no worry about conflicting with other usage.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
