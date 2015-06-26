Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B36726B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 14:42:46 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so79595500pdc.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 11:42:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fm2si51667391pab.148.2015.06.26.11.42.45
        for <linux-mm@kvack.org>;
        Fri, 26 Jun 2015 11:42:45 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 10/12] mm: add the buddy system interface
Date: Fri, 26 Jun 2015 18:42:41 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32AA065B@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com>
 <557691E0.5020203@jp.fujitsu.com> <5576BA2B.6060907@huawei.com>
 <5577A9A9.7010108@jp.fujitsu.com> <558BCD95.2090201@huawei.com>
 <558C94BB.1060304@jp.fujitsu.com> <558CAE43.4090702@huawei.com>
 <558D0E9B.8030405@jp.fujitsu.com> <558D2B8B.1060901@huawei.com>
In-Reply-To: <558D2B8B.1060901@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> gfpflags_to_migratetype()
>   if (memory_mirror_enabled()) { /* We want to mirror all unmovable pages=
 */
>       if (!(gfp_mask & __GFP_MOVABLE))
>            return MIGRATE_MIRROR
>   }

I'm not sure that we can divide memory into just two buckets of "mirrored" =
and "movable".

My expectation is that there will be memory that is neither mirrored, nor m=
ovable.  We'd
allocate that memory to user proceses.  Uncorrected errors in that memory w=
ould result
in the death of the process (except in the case where the page is a clean c=
opy mapped from
a disk file ... e.g. .text mapping instructions from an executable).  Linux=
 would offline
the affected 4K page so as not to hit the problem again.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
