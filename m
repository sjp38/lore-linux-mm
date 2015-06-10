Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1C56B0038
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 16:40:11 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so44807587pdb.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 13:40:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo6si15550259pac.151.2015.06.10.13.40.10
        for <linux-mm@kvack.org>;
        Wed, 10 Jun 2015 13:40:10 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 10/12] mm: add the buddy system interface
Date: Wed, 10 Jun 2015 20:40:08 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A8F209@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com>
 <557691E0.5020203@jp.fujitsu.com> <5576BA2B.6060907@huawei.com>
 <5577A9A9.7010108@jp.fujitsu.com>
In-Reply-To: <5577A9A9.7010108@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> I guess, mirrored memory should be allocated if !__GFP_HIGHMEM or !__GFP_=
MOVABLE

HIGHMEM shouldn't matter - partial memory mirror only makes any sense on X8=
6_64 systems ... 32-bit kernels
don't even boot on systems with 64GB, and the minimum rational configuratio=
n for a machine that supports
mirror is 128GB (4 cpu sockets * 2 memory controller per socket * 4 channel=
s per controller * 4GB DIMM ...
leaving any channels empty likely leaves you short of memory bandwidth for =
these high core count processors).

MOVABLE is mostly the opposite of MIRROR - we never want to fill a kernel a=
llocation from a MOVABLE page. I
want all kernel allocations to be from MIRROR.

-Tony


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
