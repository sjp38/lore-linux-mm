Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16D2D6B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 07:42:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t23so13653580pfe.17
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:42:12 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id l11si17864661pln.331.2017.04.12.04.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 04:42:11 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 79so4851186pgf.0
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:42:11 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] mm: add VM_STATIC flag to vmalloc and prevent from removing the areas
From: Hoeun Ryu <hoeun.ryu@gmail.com>
In-Reply-To: <20170412060218.GA16170@infradead.org>
Date: Wed, 12 Apr 2017 20:42:08 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <AC5E3048-6E2B-4DBE-80BA-AAE2D3EED969@gmail.com>
References: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com> <20170412060218.GA16170@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Apr 12, 2017, at 3:02 PM, Christoph Hellwig <hch@infradead.org> wrote:
>=20
>> On Wed, Apr 12, 2017 at 02:01:59PM +0900, Hoeun Ryu wrote:
>> vm_area_add_early/vm_area_register_early() are used to reserve vmalloc ar=
ea
>> during boot process and those virtually mapped areas are never unmapped.
>> So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
>> existing vmlist entries and prevent those areas from being removed from t=
he
>> rbtree by accident.
>=20
> How would they be removed "by accident"?

I don't mean actual use-cases, but I just want to make it robust against lik=
e programming errors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
