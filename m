Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 783746B21C7
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 21:40:10 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m185-v6so709416itm.1
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 18:40:10 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id b72-v6si184011jad.122.2018.08.21.18.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 18:40:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 0/2] mm: soft-offline: fix race against page
 allocation
Date: Wed, 22 Aug 2018 01:37:48 +0000
Message-ID: <20180822013748.GA10343@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180815154334.f3eecd1029a153421631413a@linux-foundation.org>
In-Reply-To: <20180815154334.f3eecd1029a153421631413a@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FA40E675BD186C44B3B28B91371D0A5B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Wed, Aug 15, 2018 at 03:43:34PM -0700, Andrew Morton wrote:
> On Tue, 17 Jul 2018 14:32:30 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > I've updated the patchset based on feedbacks:
> >=20
> > - updated comments (from Andrew),
> > - moved calling set_hwpoison_free_buddy_page() from mm/migrate.c to mm/=
memory-failure.c,
> >   which is necessary to check the return code of set_hwpoison_free_budd=
y_page(),
> > - lkp bot reported a build error when only 1/2 is applied.
> >=20
> >   >    mm/memory-failure.c: In function 'soft_offline_huge_page':
> >   > >> mm/memory-failure.c:1610:8: error: implicit declaration of funct=
ion
> >   > 'set_hwpoison_free_buddy_page'; did you mean 'is_free_buddy_page'?
> >   > [-Werror=3Dimplicit-function-declaration]
> >   >        if (set_hwpoison_free_buddy_page(page))
> >   >            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
> >   >            is_free_buddy_page
> >   >    cc1: some warnings being treated as errors
> >=20
> >   set_hwpoison_free_buddy_page() is defined in 2/2, so we can't use it
> >   in 1/2. Simply doing s/set_hwpoison_free_buddy_page/!TestSetPageHWPoi=
son/
> >   will fix this.
> >=20
> > v1: https://lkml.org/lkml/2018/7/12/968
> >=20
>=20
> Quite a bit of discussion on these two, but no actual acks or
> review-by's?

Really sorry for late response.
Xishi provided feedback on previous version, but no final ack/reviewed-by.
This fix should work on the reported issue, but rewriting soft-offlining
without PageHWPoison flag would be the better fix (no actual patch yet.)
I'm not sure this patch should go to mainline immediately.

Thanks,
Naoya Horiguchi=
