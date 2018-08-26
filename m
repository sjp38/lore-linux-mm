Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB79F6B3D80
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 19:51:02 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n194-v6so7126209itn.0
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 16:51:02 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id k88-v6si9419220jad.47.2018.08.26.16.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Aug 2018 16:51:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] tools/vm/slabinfo.c: fix sign-compare warning
Date: Sun, 26 Aug 2018 23:49:47 +0000
Message-ID: <20180826234947.GA9787@hori1.linux.bs1.fc.nec.co.jp>
References: <1535103134-20239-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180826022114.GA23206@bombadil.infradead.org>
In-Reply-To: <20180826022114.GA23206@bombadil.infradead.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4AAD8CA9736C6A4BBEB17E32908E4524@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Aug 25, 2018 at 07:21:14PM -0700, Matthew Wilcox wrote:
> On Fri, Aug 24, 2018 at 06:32:14PM +0900, Naoya Horiguchi wrote:
> > -	int hwcache_align, object_size, objs_per_slab;
> > -	int sanity_checks, slab_size, store_user, trace;
> > +	int hwcache_align, objs_per_slab;
> > +	int sanity_checks, store_user, trace;
> >  	int order, poison, reclaim_account, red_zone;
> > +	unsigned int object_size, slab_size;
>=20
> Surely hwcache_align and objs_per_slab can't be negative either?
> Nor the other three.  So maybe convert all seven of these variables to
> unsigned int?
>=20

Fair enough, I update the patch.
Thanks for the comment.

- Naoya

---
