Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 15469900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 13:01:11 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so34648431pdj.3
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 10:01:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ub1si6708387pac.114.2015.06.04.10.01.09
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 10:01:10 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 08/12] mm: use mirrorable to switch allocate
 mirrored memory
Date: Thu, 4 Jun 2015 17:01:08 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A8D5A2@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704C79.5060608@huawei.com>
In-Reply-To: <55704C79.5060608@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it me=
ans
> we should allocate mirrored memory for both user and kernel processes.

With some "to be defined later" mechanism for how the user requests mirror =
vs.
not mirror.  Plus some capability/ulimit pieces that restrict who can do th=
is and how
much they can get???

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
