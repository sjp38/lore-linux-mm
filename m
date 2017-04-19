Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9426B039F
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:32:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a188so7369715pfa.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 22:32:19 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id p190si1308966pfp.168.2017.04.18.22.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 22:32:18 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 63so2405906pgh.0
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 22:32:18 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2] mm: add VM_STATIC flag to vmalloc and prevent from removing the areas
From: Hoeun Ryu <hoeun.ryu@gmail.com>
In-Reply-To: <20170418065946.GB22360@dhcp22.suse.cz>
Date: Wed, 19 Apr 2017 14:32:14 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <CEE04495-95EF-4A98-A85F-5C3537072BCE@gmail.com>
References: <1492494570-21068-1-git-send-email-hoeun.ryu@gmail.com> <20170418065946.GB22360@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hch@infradead.org, khandual@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Roman Pen <r.peniaev@gmail.com>, Andreas Dilger <adilger@dilger.ca>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Apr 18, 2017, at 3:59 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
>> On Tue 18-04-17 14:48:39, Hoeun Ryu wrote:
>> vm_area_add_early/vm_area_register_early() are used to reserve vmalloc ar=
ea
>> during boot process and those virtually mapped areas are never unmapped.
>> So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
>> existing vmlist entries and prevent those areas from being removed from t=
he
>> rbtree by accident.
>=20
> Has this been a problem in the past or currently so that it is worth
> handling?
>=20
>> This flags can be also used by other vmalloc APIs to
>> specify that the area will never go away.
>=20
> Do we have a user for that?
>=20
>> This makes remove_vm_area() more robust against other kind of errors (eg.=

>> programming errors).
>=20
> Well, yes it will help to prevent from vfree(early_mem) but we have 4
> users of vm_area_register_early so I am really wondering whether this is
> worth additional code. It would really help to understand your
> motivation for the patch if we were explicit about the problem you are
> trying to solve.

I just think that it would be good to make it robust against various kind of=
 errors.
You might think that's not an enough reason to do so though.

>=20
> Thanks
>=20
> --=20
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
